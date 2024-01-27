// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { IRouter } from "../interfaces/IRouter.sol";
import { ProtectionBase } from "../ProtectionBase.sol";

/// @notice Inherit this contract to enable access to the CUBE3 Core Protocol and add function-level protection to
///         functions by adding the {cube3Protected} modifier to the function.
/// @dev The initialize functions should be caleld in the derived contract's initializer.
/// @dev See {ProtectionBase} for implementation details.
abstract contract Cube3ProtectionUpgradeable is ProtectionBase {
    /// @dev The `integrationAdmin` can be considered the owner of the this contract, from the CUBE3 protocol's
    /// perspective,
    ///      and is the account that will be permissioned to complete the registration with the protocol and
    /// enable/disable
    ///      protection for the functions decorated with the {cube3Protected} modifier.
    /// @dev MUST be called in the derived contract's initializer.
    function __Cube3ProtectionUpgradeable_init(
        address router,
        address integrationAdmin,
        bool enabledByDefault
    )
        internal
    {
        __Cube3ProtectionUpgradeable_init_unchained(router, integrationAdmin, enabledByDefault);
    }

    function __Cube3ProtectionUpgradeable_init_unchained(
        address _router,
        address _integrationAdmin,
        bool _enabledByDefault
    )
        private
    {
        _baseInitProtection(_router, _integrationAdmin, _enabledByDefault);
    }
}
