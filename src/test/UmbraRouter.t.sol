// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.6;

import "ds-test/test.sol";
import "../UmbraRouter.sol";
import "forge-std/Vm.sol";


contract UmbraRouterTest is DSTest {
    UmbraRouter router;
    address myAddr = 0xb607a2c7F78aA1d7e39a54F7c2Ee6f4d208acCA4;
    address receiver = 0xdF8d4537B9D40AA15b0D75AE45727d6A53fA46A5;
    address umbra = 0xFb2dc580Eed955B528407b4d36FfaFe3da685401;
    Vm vm = Vm(HEVM_ADDRESS);

    address[] public receivers;
    uint256[] tollCommitments;
    bytes32 pkxes;
    bytes32 ciphertexts;
    bytes payload;

    // address receiver = myAddr;
    uint public tollCommitment;

    function setUp() public {

        router = new UmbraRouter();

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
}
