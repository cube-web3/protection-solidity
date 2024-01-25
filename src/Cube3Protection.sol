// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouter} from "./interfaces/IRouter.sol";

import {ProtectionBase} from "./ProtectionBase.sol";

/// @dev See {ProtectionBase} for implementation details.
abstract contract Cube3Protection is ProtectionBase {

    /**
     * @dev Passing the zero address as the `integrationAdmin` will set the admin to the deployer by default.
     * @param router The address of the CUBE3 Router contract.
     * @param integrationAdmin The address of the integration admin. Set and managed by the CUBE3 Router.
     * @param enabledByDefault If set to true, the connection to the CUBE3 core protocol will be established by default.  
     */
    constructor(address router, address integrationAdmin, bool enabledByDefault) {
      _baseInitProtection(router, integrationAdmin, enabledByDefault);
    }

}
