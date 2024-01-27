// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseTest} from "../Base.t.sol";


contract ProtectionBaseTest is BaseTest {
  function setUp() public virtual override {
    BaseTest.setUp();
  }

  // when the router address is set, it should return the router address, it should emit the event
  
  // when the integration is set, it should emit the event

  // when the router is the correct address, the call should succeed



  // ==== fail

  // when the router address is zero, it should revert
  function test_RevertWhen_RouterIsZeroAddress() public {
   vm.expectRevert(bytes("CUBE3: Router ZeroAddress"));
   protectionBaseHarness.baseInitProtection(address(0), _randomAddress(), true);
  }

  // when the integration admin is zero, it should revert

  // when the router address is the wrong address, it should revert


}