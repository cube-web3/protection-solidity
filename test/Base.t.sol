// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

import "forge-std/Test.sol";

import { ProtectionBaseHarness } from "./harnesses/ProtectionBaseHarness.sol";

import { MockNonRouter } from "./mocks/MockNonRouter.sol";
import { MockRouter } from "./mocks/MockRouter.sol";

import { Utils } from "./utils/Utils.sol";

import { Events } from "./utils/Events.sol";

import { Errors } from "./utils/Errors.sol";

struct Users {
    // Default admin for the integration contract.
    address payable integrationAdmin;
    address payable randomUser;
}

abstract contract BaseTest is Test, Utils, Events, Errors {
    ProtectionBaseHarness internal protectionBaseHarness;

    MockRouter internal mockRouter;
    MockNonRouter internal mockNonRouter;

    Users users;

    function setUp() public virtual {
        _deployContracts();

        users =
            Users({ integrationAdmin: payable(makeAddr("integrationAdmin")), randomUser: payable(_randomAddress()) });

        _labelAccounts();
    }

    function _deployContracts() internal {
        protectionBaseHarness = new ProtectionBaseHarness();
        mockRouter = new MockRouter(true, true);
        mockNonRouter = new MockNonRouter();
    }

    function _labelAccounts() internal {
        vm.label({ account: address(protectionBaseHarness), newLabel: "Protection Base Harness" });
    }
}
