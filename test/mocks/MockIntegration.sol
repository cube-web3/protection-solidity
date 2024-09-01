// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

import {Cube3Protection} from "../../src/Cube3Protection.sol";

/// @dev This mock contract is only used to establish the contract size of the Cube3Protection contract
/// by means of a codesize comparison.
contract Mock {
    event Success();

    function mock() external {
        emit Success();
    }

    function mockInline() external {
        emit Success();
    }
}

contract MockIntegration is Cube3Protection {
    event Success();
    constructor(
        address router
    )
        Cube3Protection(
            router,
            msg.sender, // default admin
            true // connect to the protocol by default
        )
    {}

    function mockProtectedModifier(
        bytes calldata cube3Payload
    ) external cube3Protected(cube3Payload) {
        emit Success();
    }

    function mockProtectedInline(bytes calldata cube3Payload) external {
        _assertProtectWhenConnected(cube3Payload);
        emit Success();
    }
}
