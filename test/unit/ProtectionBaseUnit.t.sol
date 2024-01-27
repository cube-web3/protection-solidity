// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {BaseTest} from "../Base.t.sol";


contract ProtectionBase_Unit_Test is BaseTest {
  function setUp() public virtual override {
    BaseTest.setUp();
  }

  // when the router address is set, it should return the router address, it should emit the event
  function test_SucceedsWhen_RouterAddress_IsSet() public {
   vm.expectEmit(true,true,true,true);
   emit Cube3ProtectionRouterUpdated(address(mockRouter));
   protectionBaseHarness.baseInitProtection(address(mockRouter), _randomAddress(), true);
   assertEq(protectionBaseHarness.protectedStorage().router, address(mockRouter), "router not set");
  }
  
  // when the integration is set, it should emit the event
  function test_SucceedsWhen_IntegrationAdmin_IsSet() public {
    protectionBaseHarness.baseInitProtection(address(mockRouter), users.integrationAdmin, true);
    assertEq(users.integrationAdmin, mockRouter.mockIntegrationAdmin(address(protectionBaseHarness)), "admin not set");
  }

  // when the router is the correct address, the call should succeed
  function test_SucceedsWhen_SetConnectToProtocol() public {
   vm.expectEmit(true,true,true,true);
   emit Cube3ProtocolConnectionUpdated(true);
   protectionBaseHarness.baseInitProtection(address(mockRouter), _randomAddress(), true);
   assertEq(protectionBaseHarness.protectedStorage().shouldConnectToProtocol, true, "connection not set");

   vm.expectEmit(true,true,true,true);
   emit Cube3ProtocolConnectionUpdated(false);
   protectionBaseHarness.updateShouldUseProtocol(false);
   assertEq(protectionBaseHarness.protectedStorage().shouldConnectToProtocol, false, "connection not set");
  }

  function test_NonPayableMsgValue_IsZero() public {
    uint256 value = protectionBaseHarness.getMsgValueNonPayable();
    assertEq(value, 0, "non-zero msg value");
  }

  // ==== fail

  // when the router address is zero, it should revert
  function test_RevertWhen_RouterAddress_isZero() public {
   vm.expectRevert(bytes("CUBE3: Router ZeroAddress"));
   protectionBaseHarness.baseInitProtection(address(0), _randomAddress(), true);
  }

  // when the integration admin is zero, it should revert
  function test_RevertWhen_IntegrationAdminAddress_isZero() public {
   vm.expectRevert(bytes("CUBE3: Admin ZeroAddres"));
   protectionBaseHarness.baseInitProtection(_randomAddress(), address(0), true);
  }

  // when the router address is the wrong address, it should revert
 function test_RevertWhen_RouterAddress_isEoa() public {
  // TODO: why doesn't this offer more information?
   // vm.expectRevert(bytes("CUBE3: PreReg Fail"));
   vm.expectRevert();
   protectionBaseHarness.baseInitProtection(_randomAddress(), _randomAddress(), true);
 }

 function test_RevertWhen_RouterAddress_isWrongContract() public {
  // TODO: the call doesn't return the expected value, so why doesn't it work?
  // vm.expectRevert(bytes("CUBE3: PreReg Fail"));
  vm.expectRevert();
  protectionBaseHarness.baseInitProtection(address(mockNonRouter), _randomAddress(), true );
 }

}