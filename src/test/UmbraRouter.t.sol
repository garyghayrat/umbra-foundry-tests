// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "ds-test/test.sol";
import "../UmbraRouter.sol";
import "forge-std/Vm.sol";


contract UmbraRouterTest is DSTest {
    UmbraRouter public router;
    address umbra = 0xFb2dc580Eed955B528407b4d36FfaFe3da685401;
    address myAddr = 0xb607a2c7F78aA1d7e39a54F7c2Ee6f4d208acCA4;
    address receiver = 0xdF8d4537B9D40AA15b0D75AE45727d6A53fA46A5;

    Vm vm = Vm(HEVM_ADDRESS);

    
    bytes32 pkxes;
    bytes32 ciphertexts;
    bytes payload;

    // address receiver = myAddr;
    uint public tollCommitment;

    address payable[] public _receivers;
    address[] _tokenAddrs;
    uint256[] _amounts;
    uint256[] _tollCommitments;
    bytes32[] _pkxes;
    bytes32[] _ciphertexts;
    bytes32 test = "test";

    function setUp() public {

        router = new UmbraRouter();

        _receivers =[payable(myAddr), payable(receiver)];
        _tokenAddrs = [address(0), address(0)];
        _amounts = [0.2 ether, 0.5 ether];
        _tollCommitments = [0, 0];
        _pkxes = [test, test];
        _ciphertexts = [test, test];
        // receivers[0] = receiver;
    }

    function testExample() public {
        assertTrue(true);
        emit log_named_uint("account balance", myAddr.balance);
        emit log_named_uint("contract balance", address(this).balance);
    }

    function testSendEth() public {

 //       receivers.push(myAddr);

        // emit log_named_address("addr in array is", receivers[0]);

        payload = abi.encodeWithSignature(
          "sendEth(address,uint256,bytes32,bytes32)",
          myAddr,
          tollCommitment,
          pkxes,
          ciphertexts
        );        
        // payable(myAddr).transfer(1 ether);
        // vm.prank(myAddr);
        (bool success, ) = umbra.call{value: 1 ether}(payload);
        require(success, "call wasn't successful");
     //   assertTrue(success, "call failed");
        emit log_named_uint("account balance after call is", myAddr.balance);

        // router.batchSend([payable(receiver), payable(address(0))], [address(0x0)], [0.01 ether], [0], [empty], [empty]);
    }

    function testBatchSend() public {
        
        uint previousBal = myAddr.balance;
        uint previousBal2 = receiver.balance;
        emit log_named_uint("account balance before call is", myAddr.balance);
        emit log_named_uint("receiver account balance before call is", receiver.balance);
        emit log_named_uint("router contract balance before call is", address(router).balance);

        uint valueAmount;
        for(uint i = 0; i < _amounts.length; i++) {
            if(_tokenAddrs[i] == address(0)) {
                valueAmount += _amounts[i];
            }
        }
        router.batchSend{value: valueAmount}(_receivers, _tokenAddrs, _amounts, _tollCommitments, _pkxes, _ciphertexts);

        assertEq(myAddr.balance, (previousBal + _amounts[0]));
        assertEq(receiver.balance, (previousBal2 + _amounts[1]));
        emit log("router batchSend successful...now...");
        emit log_named_uint("account balance after call is", myAddr.balance);
        emit log_named_uint("receiver account balance before call is", receiver.balance);
        emit log_named_uint("router contract balance after call is", address(router).balance);

        
        
    }

    function testGM() public {

        string memory msg = router.gm();
        emit log_named_string("the message is", msg);
    }
}
