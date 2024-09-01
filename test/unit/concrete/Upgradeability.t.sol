// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";
import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {BaseTest} from "../../Base.t.sol";

import {Cube3ProtectionUpgradeable} from "../../../src/upgradeable/Cube3ProtectionUpgradeable.sol";

import {MockUpgradeable, MockUpgradeableV2} from "../../mocks/MockUpgradeable.sol";

contract ProtectionBase_Concrete_Unit_Test is BaseTest {
    MockUpgradeable mockUpgradeableImpl;
    MockUpgradeableV2 mockUpgradeableImplV2;
    ERC1967Proxy mockUpgradeableProxy;

    function setUp() public virtual override {
        super.setUp();
    }

    function _deployProxyAndImplementation() internal {
        mockUpgradeableImpl = new MockUpgradeable();
        vm.expectEmit(true, true, true, true);
        emit Cube3IntegrationDeployed(users.integrationAdmin, true);
        mockUpgradeableProxy = new ERC1967Proxy(
            address(mockUpgradeableImpl),
            abi.encodeCall(
                MockUpgradeable.initialize,
                (address(mockRouter), users.integrationAdmin, true)
            )
        );
        assertTrue(address(mockUpgradeableImpl) != address(0));
        assertTrue(address(mockUpgradeableProxy) != address(0));
    }

    // Succeeds deploying the proxy and initializing the implementation
    function test_SucceedsWhen_DeployingProxyAndInitializingImplementation()
        public
    {
        _deployProxyAndImplementation();
    }

    // Fails when the router address is null.
    function test_RevertsWhen_RouterAddressIsNull() public {
        mockUpgradeableImpl = new MockUpgradeable();
        vm.expectRevert(Cube3Protection_InvalidRouter.selector);
        mockUpgradeableProxy = new ERC1967Proxy(
            address(mockUpgradeableImpl),
            abi.encodeCall(
                MockUpgradeable.initialize,
                (address(0), users.integrationAdmin, true)
            )
        );
    }

    // Fails when the integration admin address is null.
    function test_RevertsWhen_IntegrationAdminAddressIsNull() public {
        mockUpgradeableImpl = new MockUpgradeable();
        vm.expectRevert(Cube3Protection_InvalidAdmin.selector);
        mockUpgradeableProxy = new ERC1967Proxy(
            address(mockUpgradeableImpl),
            abi.encodeCall(
                MockUpgradeable.initialize,
                (address(mockRouter), address(0), true)
            )
        );
    }

    // Fails when the PreRegistration call to the router fails.
    function test_RevertsWhen_PreRegistrationFails() public {
        mockUpgradeableImpl = new MockUpgradeable();
        mockRouter.updateRegistrationShouldSucceed(false);
        vm.expectRevert(Cube3Protection_PreRegistrationFailed.selector);
        mockUpgradeableProxy = new ERC1967Proxy(
            address(mockUpgradeableImpl),
            abi.encodeCall(
                MockUpgradeable.initialize,
                (address(mockRouter), users.integrationAdmin, false)
            )
        );
    }

    // Succeeds when upgrading the implementation and checking storage changes.
    function test_SucceedsWhen_UpgradingTheImplementation() public {
        bool connectToCube3ProtocolByDefault = false;

        bytes32 stateArg1 = keccak256("state1");
        bytes32 stateArg2 = keccak256("state2");

        vm.startPrank(users.integrationAdmin);
        mockUpgradeableImpl = new MockUpgradeable();
        mockUpgradeableProxy = new ERC1967Proxy(
            address(mockUpgradeableImpl),
            abi.encodeCall(
                MockUpgradeable.initialize,
                (
                    address(mockRouter),
                    users.integrationAdmin,
                    connectToCube3ProtocolByDefault
                )
            )
        );

        MockUpgradeable(address(mockUpgradeableProxy)).protectedFunction(
            stateArg1,
            new bytes(0)
        );

        // upgrade the implementation
        mockUpgradeableImplV2 = new MockUpgradeableV2();

        vm.expectEmit(true, true, true, true);
        emit ERC1967Utils.Upgraded(address(mockUpgradeableImplV2));
        MockUpgradeable(address(mockUpgradeableProxy)).upgradeToAndCall(
            address(mockUpgradeableImplV2),
            new bytes(0)
        );
        vm.stopPrank();

        MockUpgradeableV2(address(mockUpgradeableProxy)).protectedFunctionV2(
            stateArg2,
            new bytes(0)
        );

        assertEq(
            MockUpgradeableV2(address(mockUpgradeableProxy)).state(),
            stateArg1
        );
        assertEq(
            MockUpgradeableV2(address(mockUpgradeableProxy)).stateV2(),
            stateArg2
        );
    }
}
