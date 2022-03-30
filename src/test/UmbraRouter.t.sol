// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../UmbraRouter.sol";
import "forge-std/Vm.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract UmbraRouterTest is DSTest {
    UmbraRouter public router;
    address umbra = 0xFb2dc580Eed955B528407b4d36FfaFe3da685401;
    address myAddr = 0xb607a2c7F78aA1d7e39a54F7c2Ee6f4d208acCA4;
    address receiver = 0xdF8d4537B9D40AA15b0D75AE45727d6A53fA46A5;
    address Dai = 0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735;

    Vm vm = Vm(HEVM_ADDRESS);

    bytes payload;

    // address receiver = myAddr;
    uint public tollCommitment;
    bytes32 test = "test";

    UmbraRouter.SendEth newSendEth;
    UmbraRouter.SendEth[] sendeth;
    
    UmbraRouter.SendToken newSendToken;
    UmbraRouter.SendToken[] sendToken;

    uint256 amount;
    uint256 amount2;
    uint256 amount3;

    IERC20 token;

    function setUp() public {

        router = new UmbraRouter();

        amount = 1000;
        amount2 = 0.5 ether;
        amount3 = 1;

        newSendEth = UmbraRouter.SendEth(payable(receiver), amount, test, test);

        sendeth.push(UmbraRouter.SendEth(payable(myAddr), amount2, test, test));
        sendeth.push(newSendEth);

        newSendToken = UmbraRouter.SendToken(receiver, address(Dai), amount3, test, test);
        sendToken.push(newSendToken);
        sendToken.push(UmbraRouter.SendToken(myAddr, address(Dai), amount3, test, test));

        token = IERC20(address(Dai));
    }

    function testExample() public {
        assertTrue(true);
        emit log_named_uint("account balance", myAddr.balance);
        emit log_named_uint("contract balance", address(this).balance);
    }

//     function testSendEth() public {

//  //       receivers.push(myAddr);

//         // emit log_named_address("addr in array is", receivers[0]);

//         payload = abi.encodeWithSignature(
//           "sendEth(address,uint256,bytes32,bytes32)",
//           myAddr,
//           tollCommitment,
//           pkxes,
//           ciphertexts
//         );        
//         // payable(myAddr).transfer(1 ether);
//         // vm.prank(myAddr);
//         (bool success, ) = umbra.call{value: 1 ether}(payload);
//         require(success, "call wasn't successful");
//      //   assertTrue(success, "call failed");
//         emit log_named_uint("account balance after call is", myAddr.balance);

//         // router.batchSend([payable(receiver), payable(address(0))], [address(0x0)], [0.01 ether], [0], [empty], [empty]);
//     }

    function testSendToken() public {


      bytes memory data = abi.encodeWithSelector(
            IUmbra.sendToken.selector,
            receiver,
            Dai, 
            1000,
            test, 
            test);

        // emit log_named_uint("account balance before call is", previousBal);
        // emit log_named_uint("receiver balance before call is", previousBal2);

        emit log_named_uint("This caller's dai balance is", token.balanceOf(address(this)));



        // vm.startPrank(myAddr);
        // token.approve(address(this), 1000);
        // vm.stopPrank();

        // token.transferFrom(myAddr, address(this), 1000);

        vm.startPrank(address(myAddr));

        token.transfer(address(this), 2000);
        vm.stopPrank();

        emit log_named_address("this address is ", address(this));
        emit log_named_uint("This caller's dai balance is now", token.balanceOf(address(this)));
        emit log_named_uint("myAddr dai balance is now", token.balanceOf(myAddr));
        emit log_named_uint("Umbra dai balance is now", token.balanceOf(umbra));

 
        token.approve(umbra, type(uint256).max);
  //      token.transfer(receiver, 1000);
        (bool success, ) = umbra.call(data);
        require(success, "call failed");
        emit log_named_uint("Receiver dai balance is now", token.balanceOf(receiver));
        emit log_named_uint("Umbra dai balance is now", token.balanceOf(umbra));

        // require(success, "call wasn't successful");

    }
 

    function testBatchSendEth() public {
        uint previousBal = myAddr.balance;
        uint previousBal2 = receiver.balance;
        emit log_named_uint("account balance before call is", myAddr.balance);
        emit log_named_uint("receiver account balance before call is", receiver.balance);
        emit log_named_uint("router contract balance before call is", address(router).balance);

        uint amount = 1 ether;
        uint256 toll = 0;        
        router.batchSendEth{value: 1.5 ether}(toll, sendeth);

        assertEq(myAddr.balance, (previousBal + sendeth[0].amount));
        assertEq(receiver.balance, (previousBal2 + sendeth[1].amount));
        emit log("router batchSend successful...now...");
        emit log_named_uint("account balance after call is", myAddr.balance);
        emit log_named_uint("receiver account balance after call is", receiver.balance);
        emit log_named_uint("router contract balance after call is", address(router).balance);

    }

        function testBatchSendTokens() public {
        uint previousBal = token.balanceOf(myAddr);
        uint previousBal2 = token.balanceOf(receiver);
        emit log_named_uint("account balance before call is", previousBal);
        emit log_named_uint("receiver balance before call is", previousBal2);

        emit log_named_uint("This caller's dai balance is", token.balanceOf(address(this)));

        vm.startPrank(myAddr);
        token.approve(address(this), 1000);
        vm.stopPrank();

        token.transferFrom(myAddr, address(this), 1000);
        emit log_named_uint("This caller's dai balance is now", token.balanceOf(address(this)));
        emit log_named_uint("This caller's dai allowance", token.allowance(address(router), address(umbra)));
        emit log_named_uint("myAddr dai balance is now", token.balanceOf(myAddr));
        emit log_named_uint("Umbra dai balance is now", token.balanceOf(umbra));


        // token.approve(umbra, 1000);

        uint amount = 1 ether;
        uint256 toll = 0;
        // token.approve(address(router), 1000);
              token.approve(address(router), type(uint256).max);
            //   token.transfer(address(router), 1000);
        
        router.batchSendTokens{value: toll}(toll, sendToken);
        emit log_named_uint("This caller's dai allowance", token.allowance(address(router), address(umbra)));

        emit log_named_uint("sendToken receiver amount is ", sendToken[0].amount);
        emit log_named_uint("This caller's dai balance is now", token.balanceOf(address(this)));
        emit log_named_uint("Umbra dai balance is now", token.balanceOf(umbra));
        



    }
}
