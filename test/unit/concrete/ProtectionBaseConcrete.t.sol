// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {BaseTest} from "../../Base.t.sol";

contract ProtectionBase_Concrete_Unit_Test is BaseTest {
    function setUp() public virtual override {
        super.setUp();
    }

    /////////////////////////////////////////////////////////////////////////////////
    //                             _baseInitProtection                             //
    /////////////////////////////////////////////////////////////////////////////////

    // ================== Success

    // when the router address is set, it should return the router address, it should emit the event
    function test_SucceedsWhen_RouterAddress_IsSet() public {
        address admin = _randomAddress();
        bool connectionEnabled = true;
        vm.expectEmit(true, true, true, true);
        emit Cube3IntegrationDeployed(admin, connectionEnabled);
        protectionBaseHarness.baseInitProtection(
            address(mockRouter),
            admin,
            connectionEnabled
        );
        assertEq(
            protectionBaseHarness.protectedStorage().router,
            address(mockRouter),
            "router not set"
        );
    }

    // when the integration is set, it should emit the event
    function test_SucceedsWhen_IntegrationAdmin_IsSet() public {
        protectionBaseHarness.baseInitProtection(
            address(mockRouter),
            users.integrationAdmin,
            true
        );
        assertEq(
            users.integrationAdmin,
            mockRouter.mockIntegrationAdmin(address(protectionBaseHarness)),
            "admin not set"
        );
    }

    // when the router is the correct address, the call should succeed
    function test_SucceedsWhen_SetConnectToProtocol() public {
        address integrationAdmin = _randomAddress();
        vm.expectEmit(true, true, true, true);
        emit Cube3IntegrationDeployed(integrationAdmin, true);
        protectionBaseHarness.baseInitProtection(
            address(mockRouter),
            integrationAdmin,
            true
        );
        assertEq(
            protectionBaseHarness.protectedStorage().shouldCheckFnProtection,
            true,
            "connection not set"
        );
    }

    // ================== Failure

    // when the router address is zero, it should revert
    function test_RevertWhen_RouterAddress_isZero() public {
        vm.expectRevert(Cube3Protection_InvalidRouter.selector);
        protectionBaseHarness.baseInitProtection(
            address(0),
            _randomAddress(),
            true
        );
    }

    // when the integration admin is zero, it should revert
    function test_RevertWhen_IntegrationAdminAddress_isZero() public {
        vm.expectRevert(Cube3Protection_InvalidAdmin.selector);
        protectionBaseHarness.baseInitProtection(
            _randomAddress(),
            address(0),
            true
        );
    }

    // when the router address is the wrong address, it should revert
    function test_RevertWhen_RouterAddress_isEoa() public {
        // revert data is empty when caught in the catch block
        vm.expectRevert();
        protectionBaseHarness.baseInitProtection(
            _randomAddress(),
            _randomAddress(),
            true
        );
    }

    function test_RevertWhen_RouterAddress_isWrongContract() public {
        // revert data is empty when caught in the catch block
        vm.expectRevert();
        protectionBaseHarness.baseInitProtection(
            address(mockNonRouter),
            _randomAddress(),
            true
        );
    }

    //////////////////////////////////////////////////////////////////////////
    //                             cube3Protected                           //
    //////////////////////////////////////////////////////////////////////////

    // when the connection is established and the payload is a valid length, it should suceed
    function test_SucceedsWhen_ConnectionIsEstablished() public {
        // create a payload with the minimum viable length
        bytes memory payload = new bytes(32);

        protectionBaseHarness.baseInitProtection(
            address(mockRouter),
            users.integrationAdmin,
            true
        );
        vm.expectEmit(true, true, true, true);
        emit CallSucceeded();
        protectionBaseHarness.cube3ProtectedModifier(payload);
    }

    // when the connection is not established, it should succeed, even with an invalid payload
    function test_SuccedsWhen_ConnectionIsNotEstablished() public {
        // create an invalid payload
        bytes memory payload = new bytes(0);

        protectionBaseHarness.baseInitProtection(
            address(mockRouter),
            users.integrationAdmin,
            false
        );
        vm.expectEmit(true, true, true, true);
        emit CallSucceeded();
        protectionBaseHarness.cube3ProtectedModifier(payload);
    }

    //////////////////////////////////////////////////////////////////////////
    //                     _assertShouldProceedAndCall                     //
    //////////////////////////////////////////////////////////////////////////

    // when the router is set correctly, it should succeed

    // when the router is an EOA, it should fail

    // when the router is the incorrect contract, it should fail

    /////////////////////////////////////////////////////////////////////////
    //                             _getMsgValue                            //
    /////////////////////////////////////////////////////////////////////////

    // when the outer function is non-payable, it should return 0
    function test_NonPayableMsgValue_IsZero() public {
        uint256 value = protectionBaseHarness.getMsgValueNonPayable();
        assertEq(value, 0, "non-zero msg value");
    }
}
