// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouter} from "./interfaces/IRouter.sol";
import {ProtectionBase} from "./ProtectionBase.sol";

/*//////////////////////////////////////////////////////////////
            MUTABLE VERSION
//////////////////////////////////////////////////////////////*/

/// @dev The mutable version allows the connection to the protocol to be severed by setting the router address to the zero address.
///      This comes at the expense of an SLOAD to retrieve the router address from storage, but allows for a a trustless integration.
abstract contract Cube3ProtectionMutable is ProtectionBase {
    address private cube3Router;

    event RouterUpdated(address indexed newRouter);

    /// @dev The `integrationAdmin` can be considered the owner of the this contract, from the CUBE3 protocol's perspective,
    ///       and is the account that will be permissioned to complete the registration with the protocol and enable/disable
    ///       protection for the functions decorated with the {cube3Protected} modifier.
    constructor(address _router, address integrationAdmin) {
        cube3Router = _router;

        // TODO: will this succeed if the router address is wrong?
        //   bytes memory preRegisterCalldata = abi.encodeWithSignature("initiateIntegrationRegistration(admin)", integrationAdmin);
        //   (bool success, ) = cube3Router.call(preRegisterCalldata);
        bool preRegistrationSucceeded = IRouter(cube3Router).initiateIntegrationRegistration(integrationAdmin);
        require(preRegistrationSucceeded, "pre-registration failed");
    }

    /// @dev Setting the cube3Router to the zero address will disconnect this contract from the CUBE3 protocol
    ///      and skip all calls to the router.
    modifier cube3Protected(bytes calldata cube3Payload) {
        if (cube3Router != address(0)) {
            _assertShouldProceedWithCall(cube3Router, cube3Payload);
        }
        _;
    }

    /// @dev Setting this to the zero address will disable the protection functionality by
    /// severing the connection to the protocol. Setting it to an incorrect address will cause calls
    /// to revert.
    /// @dev MUST only be called within an external fn protected by access control.
    function _warning_updateCube3Router(address newRouter) internal {
        cube3Router = newRouter;
        emit RouterUpdated(newRouter);
    }
}
