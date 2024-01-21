// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouter} from "./interfaces/IRouter.sol";

import {ProtectionBase} from "./ProtectionBase.sol";

/*//////////////////////////////////////////////////////////////
            IMMUTABLE VERSION
//////////////////////////////////////////////////////////////*/

/// @dev the immutable version cannot be upgraded, and the connection to the protocol cannot
/// be severed. This saves the SLOAD of retrieving the router address from storage.
/// Connection to the protocol is done on the router side, which means a call will always be made
/// to the router, and the status checked on the router-side. This requires a higher level of trust that the
/// router will not be upgraded to a non-operational version.

abstract contract Cube3ProtectionImmutable is ProtectionBase {
    address private immutable cube3Router;

    modifier cube3Protected(bytes calldata cube3Payload) {
        _assertShouldProceedWithCall(cube3Router, cube3Payload);
        _;
    }

    /// @dev The `integrationAdmin` can be considered the owner of the this contract, from the CUBE3 protocol's perspective,
    ///       and is the account that will be permissioned to complete the registration with the protocol and enable/disable
    ///       protection for the functions decorated with the {cube3Protected} modifier.
    constructor(address _router, address _integrationAdmin) {
        require(_router != address(0), "Invalid: Router ZeroAddress");
        require(_integrationAdmin != address(0), "Invalid: Admin ZeroAddress");
        cube3Router = _router;

        // TODO: will this succeed if the router address is wrong?
        //   bytes memory preRegisterCalldata = abi.encodeWithSignature("initiateIntegrationRegistration(admin)", integrationAdmin);
        //   (bool success, ) = cube3Router.call(preRegisterCalldata);
        bool preRegistrationSucceeded = IRouter(cube3Router).initiateIntegrationRegistration(_integrationAdmin);
        require(preRegistrationSucceeded, "pre-registration failed");
    }
}