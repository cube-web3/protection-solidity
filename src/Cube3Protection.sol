// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

import { ICube3RouterMinimal } from "./interfaces/ICube3RouterMinimal.sol";

import { ProtectionBase } from "./ProtectionBase.sol";

/// @title Cube3Protection
/// @notice Provides access to the CUBE3 Core Protocol and adds function-level protection to
/// functions by adding the {cube3Protected} modifier any functions in the derived contract.
/// @dev The `cube3Protected` modifier is defined in {ProtectionBase}. Review the contract for implementation details.
abstract contract Cube3Protection is ProtectionBase {
    /// @notice Initializes the CUBE3 Protection Base contract.
    /// @param router The address of the CUBE3 Router contract.
    /// @param integrationAdmin The address of the integration admin. Set and managed by the CUBE3 Router.
    /// @param enabledByDefault If set to true, the connection to the CUBE3 core protocol will be established by
    /// default.
    constructor(address router, address integrationAdmin, bool enabledByDefault) {
        _baseInitProtection(router, integrationAdmin, enabledByDefault);
    }
}
