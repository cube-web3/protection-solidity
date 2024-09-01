// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {BaseTest} from "../../Base.t.sol";

import {MockIntegration, Mock} from "../../mocks/MockIntegration.sol";

contract Integration_Concrete_Unit_Test is BaseTest {
    MockIntegration mockIntegration;
    Mock mock;

    event Success();

    function setUp() public override {
        super.setUp();
        mockIntegration = new MockIntegration(address(mockRouter));
        mock = new Mock();
    }

    function test_codeSize() public {
        mockIntegration.mockProtectedModifier(new bytes(32));
        mock.mock();
    }

    function test_SucceedsWhen_CallingProtectedFn_WithModifier() public {
        vm.expectEmit(true, true, true, true);
        emit Success();
        mockIntegration.mockProtectedModifier(new bytes(32));
    }

    function test_SucceedsWhen_CallingProtectedFn_WithInlineAssertion() public {
        vm.expectEmit(true, true, true, true);
        emit Success();
        mockIntegration.mockProtectedInline(new bytes(32));
    }
}
