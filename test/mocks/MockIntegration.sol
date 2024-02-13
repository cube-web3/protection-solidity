// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.8.24;

import {Cube3Protection} from "../../src/Cube3Protection.sol";

contract MockIntegration is Cube3Protection {

 event Success();
 constructor(address router) 
 Cube3Protection(
  router,
  msg.sender, // default admin
  true // connect to the protocol by default  
 ) {}

 function mockProtected(bytes calldata cube3Payload) cube3Protected(cube3Payload) external {
  emit Success();
 }
}