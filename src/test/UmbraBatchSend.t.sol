// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "forge-std/Vm.sol";
import "forge-std/stdlib.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../UmbraBatchSend.sol";

contract UmbraBatchSendTest is DSTest, stdCheats {
    using stdStorage for StdStorage;
    StdStorage stdstore;

    UmbraBatchSend public router = new UmbraBatchSend();

    string constant umbraArtifact = 'artifacts/Umbra.json';
    string constant testArtifact = 'out/UmbraBatchSend.t.sol/UmbraBatchSendTest.json';
    string constant testArtifact2 = 'out/UmbraBatchSend.sol/UmbraBatchSend.json';


    address umbra = 0xFb2dc580Eed955B528407b4d36FfaFe3da685401;
    address myAddr = 0xb607a2c7F78aA1d7e39a54F7c2Ee6f4d208acCA4;
    address receiver = 0xdF8d4537B9D40AA15b0D75AE45727d6A53fA46A5;
    address Dai = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;

    address alice = address(0x202204);
    address bob = address(0x202205);



    Vm vm = Vm(HEVM_ADDRESS);
    bytes payload;

    uint public tollCommitment;
    bytes32 test = "test";

    UmbraBatchSend.SendEth newSendEth;
    UmbraBatchSend.SendEth[] sendEth;
    
    UmbraBatchSend.SendToken newSendToken;
    UmbraBatchSend.SendToken[] sendToken;

    IERC20 token = IERC20(address(Dai));

    function setUp() public {

        vm.label(alice, "Alice");
        vm.label(bob, "Bob");
        vm.label(address(this), "TestContract");

        // address umbraClone = deployCode(umbraArtifact);
        // emit log_named_address("umbraClone address is ", umbraClone);

         stdstore
            .target(Dai)
            .sig(IERC20(token).balanceOf.selector)
            .with_key(address(this))
            .checked_write(1000*1e18);
    }

    function testDeployCode() public {
        address deployed = deployCode(testArtifact, bytes(""));
        emit log_named_address("deployed address is", deployed);
        assertEq(string(getCode(deployed)), string(getCode(address(this))));
    }

    function testUmbraDeploy() public {
        address deployed = deployCode("UmbraBatchSend.sol:UmbraBatchSend", bytes(""));
        emit log_named_address("deployed address is", deployed);
        // assertEq(string(getCode(deployed)), string(getCode(address(this))));
    }

    function getCode(address who) internal view returns (bytes memory o_code) {
        assembly {
            // retrieve the size of the code, this needs assembly
            let size := extcodesize(who)
            // allocate output byte array - this could also be done without assembly
            // by using o_code = new bytes(size)
            o_code := mload(0x40)
            // new "memory end" including padding
            mstore(0x40, add(o_code, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            // store length in memory
            mstore(o_code, size)
            // actually retrieve the code, this needs assembly
            extcodecopy(who, add(o_code, 0x20), 0, size)
        }
    }    

    function testBatchSendEth() public {

        uint alicePrevBal = alice.balance;
        uint bobPrevBal = bob.balance;

        uint amount = 1 ether;
        uint amount2 = 2 ether;
        uint256 toll = 0;        

        sendEth.push(UmbraBatchSend.SendEth(payable(alice), amount, test, test));
        sendEth.push(UmbraBatchSend.SendEth(payable(bob), amount2, test, test));
        router.batchSendEth{value: amount + amount2}(toll, sendEth);

        assertEq(alice.balance, alicePrevBal + amount);
        assertEq(bob.balance, bobPrevBal + amount2);

    }

    function testFuzz_BatchSendEth(uint8 amount, uint8 amount2, bytes32 testBytes) public {

        uint alicePrevBal = alice.balance;
        uint bobPrevBal = bob.balance;
        vm.assume(amount > 0 && amount < type(uint8).max/2);
        vm.assume(amount2 > 0 && amount2 < type(uint8).max/2);
        

        uint256 toll = 0;

        sendEth.push(UmbraBatchSend.SendEth(payable(alice), amount, testBytes, testBytes));
        sendEth.push(UmbraBatchSend.SendEth(payable(bob), amount2, testBytes, testBytes));

        uint totalAmount = amount + amount2;

        router.batchSendEth{value: totalAmount}(toll, sendEth);

        assertEq(alice.balance, alicePrevBal + amount);
        assertEq(bob.balance, bobPrevBal + amount2);

    }

    function testBatchSendTokens() public {

        assertTrue(token.balanceOf(address(this)) > 0, "caller's dai balance is zero");

        uint256 toll = 0;
        uint umbraPrevBal = token.balanceOf(umbra);

        sendToken.push(UmbraBatchSend.SendToken(alice, Dai, 1000, test, test));
        sendToken.push(UmbraBatchSend.SendToken(bob, Dai, 500, test, test));
        token.approve(address(router), 1500);

        router.batchSendTokens{value: toll}(toll, sendToken);
        assertEq(token.balanceOf(umbra), umbraPrevBal + 1500);

    }

    function testFuzz_BatchSendTokens(uint8 amount, uint8 amount2) public {

        assertTrue(token.balanceOf(address(this)) > 0, "caller's dai balance is zero");

        vm.assume(amount < type(uint8).max/2);
        vm.assume(amount2 < type(uint8).max/2);

        uint256 toll = 0;
        uint umbraPrevBal = token.balanceOf(umbra);

        sendToken.push(UmbraBatchSend.SendToken(alice, Dai, amount, test, test));
        sendToken.push(UmbraBatchSend.SendToken(bob, Dai, amount2, test, test));
        token.approve(address(router), amount + amount2);

        router.batchSendTokens{value: toll}(toll, sendToken);
        assertEq(token.balanceOf(umbra), umbraPrevBal + amount + amount2);

    }

    function testBatchSend() public {

        uint alicePrevBal = alice.balance;
        uint bobPrevBal = bob.balance;

        uint amount = 1 ether;
        uint amount2 = 2 ether;
        uint total = amount + amount2;
        uint256 toll = 0;        

        sendEth.push(UmbraBatchSend.SendEth(payable(alice), amount, test, test));
        sendEth.push(UmbraBatchSend.SendEth(payable(bob), amount2, test, test));

        //tokens
        assertTrue(token.balanceOf(address(this)) > 0, "caller's dai balance is zero");

        uint umbraPrevBal = token.balanceOf(umbra);

        sendToken.push(UmbraBatchSend.SendToken(alice, Dai, 1000, test, test));
        sendToken.push(UmbraBatchSend.SendToken(bob, Dai, 500, test, test));
        token.approve(address(router), 1500);

        router.batchSend{value: total + toll}(toll, sendEth, sendToken);

        assertEq(alice.balance, alicePrevBal + amount);
        assertEq(bob.balance, bobPrevBal + amount2);

        assertEq(token.balanceOf(umbra), umbraPrevBal + 1500);

    }

    function testFuzz_BatchSend(uint8 amount, uint8 amount2, bytes32 testBytes) public {

        uint alicePrevBal = alice.balance;
        uint bobPrevBal = bob.balance;
        uint umbraPrevBal = token.balanceOf(umbra);
        vm.assume(amount > 0 && amount < type(uint8).max/2);
        vm.assume(amount2 > 0 && amount2 < type(uint8).max/2);
        assertTrue(token.balanceOf(address(this)) > 0, "caller's dai balance is zero");

        uint256 toll = 0;
        uint totalAmount = amount + amount2;

        sendEth.push(UmbraBatchSend.SendEth(payable(alice), amount, testBytes, testBytes));
        sendEth.push(UmbraBatchSend.SendEth(payable(bob), amount2, testBytes, testBytes));

        sendToken.push(UmbraBatchSend.SendToken(alice, Dai, amount, test, test));
        sendToken.push(UmbraBatchSend.SendToken(bob, Dai, amount2, test, test));
        token.approve(address(router), amount + amount2);

        router.batchSend{value: totalAmount + toll}(toll, sendEth, sendToken);

        assertEq(alice.balance, alicePrevBal + amount);
        assertEq(bob.balance, bobPrevBal + amount2);

        assertEq(token.balanceOf(umbra), umbraPrevBal + amount + amount2);

    }

}
