// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.8.24;

import { BaseTest } from "../../Base.t.sol";

import {MockIntegration} from "../../mocks/MockIntegration.sol";

contract Integration_Concrete_Unit_Test is BaseTest {
 MockIntegration mockIntegration;

 event Success();
 
 function setUp() override public {
  super.setUp();
  mockIntegration = new MockIntegration(address(mockRouter));
 }

 function test_SucceedsWhen_CallingProtectedFn() public {
  vm.expectEmit(true,true,true,true);
  emit Success();
  mockIntegration.mockProtected(new bytes(32));
 }
}