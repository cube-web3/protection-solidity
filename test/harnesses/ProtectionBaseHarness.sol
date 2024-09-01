// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

import { ProtectionBase } from "../../src/ProtectionBase.sol";

import { Events } from "../utils/Events.sol";

/// @notice Harness contract that enables the testing of {ProtectionBase} internal functions.
contract ProtectionBaseHarness is ProtectionBase {
    // Emitted when a generic function call succeeds;
    event CallSucceeded();

    function baseInitProtection(address router_, address admin_, bool connectionEstablished_) external {
        _baseInitProtection(router_, admin_, connectionEstablished_);
    }

    /// @dev The `msgDataSeed` is unused, and not relative to the {_assertShouldProceedWtihCall}. We
    ///      only utilize it when fuzzing the msg.data forwarded to the router
    function assertShouldProceedAndCall(bytes32 msgDataSeed) external payable {
        // ignore compiler warnings for unused variable.
        (msgDataSeed);
        _assertShouldProceedAndCall();
    }

    function assertShouldProceedAndCall() external {
        _assertShouldProceedAndCall();
    }

    function protectedStorage() external pure returns (ProtectedStorage memory cube3Storage) {
        return _cube3Storage();
    }

    function updateShouldUseProtocol(bool shouldConnect) external {
        _updateShouldUseProtocol(shouldConnect);
    }

    function getMsgValuePayable() external payable returns (uint256) {
        return _getMsgValue();
    }

    function getMsgValueNonPayable() external view returns (uint256) {
        return _getMsgValue();
    }

    function cube3ProtectedModifier(bytes calldata payload) external cube3Protected(payload) {
        emit CallSucceeded();
    }
}
