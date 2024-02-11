// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.8.24;

import { ICube3RouterMinimal } from "./interfaces/ICube3RouterMinimal.sol";

/// @dev Function visibility is set to `internal` instead of `private` to allow for testing via
///      a harness contract.
abstract contract ProtectionBase {
    /////////////////////////////////////////////////////////////////////////
    //                             CONSTANTS                               //
    /////////////////////////////////////////////////////////////////////////

    // Expected hashed return value from the router indicating the call is safe to proceed.
    bytes32 private constant PROCEED_WITH_CALL = keccak256("CUBE3_PROCEED_WITH_CALL");

    // Expected hashed return value from the router indicating the pre-registration and setting of the admin succeeded.
    bytes32 private constant PRE_REGISTRATION_SUCCEEDED = keccak256("CUBE3_PRE_REGISTRATION_SUCCEEDED");

    // ERC7201 namespace derivation for storage layout.
    // keccak256(abi.encode(uint256(keccak256("cube3.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant CUBE3_PROTECTED_STORAGE_LOCATION =
        0xd26911dcaedb68473d1e75486a92f0a8e6ef3479c0c1c4d6684d3e2888b6b600;

    // The minimum payload length is equivalent to the payload routing bitmap (uint256) size.
    uint256 private constant MINIMUM_PAYLOAD_LENGTH_BYTES = 32;

    /////////////////////////////////////////////////////////////////////////
    //                             EVENTS                                  //
    /////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when the CUBE3 router address is updated.
    event Cube3ProtectionRouterUpdated(address newRouter);

    /// @notice Emitted when the connection to the CUBE3 protocol is updated.
    event Cube3ProtocolConnectionUpdated(bool connectionEstablished);

    /// @notice Emitted when this integration is deployed.
    event Cube3IntegrationDeployed(address indexed integrationAdmin, address router, bool enabledByDefault);

    /////////////////////////////////////////////////////////////////////////
    //                             ERRORS                                  //
    /////////////////////////////////////////////////////////////////////////

    /// @notice Thrown when the router address is set to the zero address.
    error Cube3Protection_InvalidRouter();

    /// @notice Thrown when the integration admin address is set to the zero address.
    error Cube3Protection_InvalidAdmin();

    /// @notice Thrown when the CUBE3 Router returns an invalid value.
    error Cube3Protection_InvalidRouterReturn();

    /// @notice Thrown when the CUBE3 Payload provided is an invalid size.
    error Cube3Protection_InvalidPayloadSize();

    /// @notice Thrown when pre-registration with the CUBE3 Router fails.
    error Cube3Protection_PreRegistrationFailed();

    /////////////////////////////////////////////////////////////////////////
    //                             STORAGE                                 //
    /////////////////////////////////////////////////////////////////////////

    /// @custom:storage-location erc7201:cube3.storage
    /// @param router The address of the CUBE3 router contract. Security modules are accessed via the router.
    /// @param shouldCheckFnProtection Determines whether to establish a connection to the protocol.  If set
    /// to true, a call will be made to the router where the protection status of the function will be evaluated
    /// and the call will be forwarded to the appropriate security module if protection is enabled.
    struct ProtectedStorage {
        address router;
        bool shouldCheckFnProtection;
    }

    /////////////////////////////////////////////////////////////////////////
    //                             MODIFIERS                               //
    /////////////////////////////////////////////////////////////////////////

    /// @dev Adding this modifier to a function adds the ability to apply function-level protection to the function.
    /// If the connection to the protocol is established, all calls are diverted to the CUBE3 Router.
    /// @dev If utilized, the protocol will forward the calldata to the module designated in the payload's routing
    /// footer.
    modifier cube3Protected(bytes calldata cube3Payload) {
        // Checks: the payload should be forwared to the CUBE3 protocol.
        if (_cube3Storage().shouldCheckFnProtection) {
            // Checks: the payload meets the minimum criteria.
            if (cube3Payload.length < MINIMUM_PAYLOAD_LENGTH_BYTES) {
                revert Cube3Protection_InvalidPayloadSize();
            }

            // Interactions: forward the calldata, including the payload, along with the call context, to the CUBE3
            // protocol where it will be routed to the desired security module.
            _assertShouldProceedAndCall();
        }
        _;
    }

    /////////////////////////////////////////////////////////////////////////
    //                             INITIALIZATION                          //
    /////////////////////////////////////////////////////////////////////////

    /**
     * @dev Called by the derived contract's initializer or constructor to set the router address and integration admin.
     * @param router The address of the CUBE3 Router contract.
     * @param integrationAdmin The address of the integration admin. Set and managed by the CUBE3 Router.
     * @param enabledByDefault If set to true, the connection to the CUBE3 core protocol will be established by default.
     */
    function _baseInitProtection(address router, address integrationAdmin, bool enabledByDefault) internal {
        // Checks: the router address is provided.
        if (router == address(0)) {
            revert Cube3Protection_InvalidRouter();
        }

        // Checks: the integration admin is provided.
        if (integrationAdmin == address(0)) {
            revert Cube3Protection_InvalidAdmin();
        }

        // Set the router address.
        _cube3Storage().router = router;

        // Enable/disable the connection to the CUBE3 core protocol.
        _cube3Storage().shouldCheckFnProtection = enabledByDefault;

        // Interactions: pre-register this integration with the router and set this contract's admin address. This call
        // serves the dual purpose of validating that the correct router address was passed in the constructor and
        // setting the admin.
        (bool success, bytes memory data) = router.call(
            abi.encodeWithSelector(ICube3RouterMinimal.initiateIntegrationRegistration.selector, (integrationAdmin))
        );
        if (!success || abi.decode(data, (bytes32)) != PRE_REGISTRATION_SUCCEEDED) {
            revert Cube3Protection_PreRegistrationFailed();
        }

        // Log: the creation of the integration and the default config.
        emit Cube3IntegrationDeployed(integrationAdmin, router, enabledByDefault);
    }

    /// @dev The payload is not explicitly passed passed to the router as it's implicitly encoded in the msg.data
    /// used to construct the calldata for the `routeToModule` call.
    function _assertShouldProceedAndCall() internal {
        try ICube3RouterMinimal(_cube3Storage().router).routeToModule(msg.sender, _getMsgValue(), msg.data) returns (
            bytes32 result
        ) {
            // Checks: the call succeeded with the expected return value.
            if (result != PROCEED_WITH_CALL) {
                revert Cube3Protection_InvalidRouterReturn();
            }
            return;
        } catch (bytes memory revertData) {
            // Bubble up the revert data to capture the original error from the protocol.
            assembly {
                revert(add(revertData, 0x20), mload(revertData))
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////
    //                              STORAGE                                //
    /////////////////////////////////////////////////////////////////////////

    /// @dev WARNING: This MUST only be called within an external/public fn by an account with elevated privileges.
    /// @dev If the derived contract has no access control, this function should not be exposed and the connection
    ///      to the protocol is locked at the time of deployment.
    function _updateShouldUseProtocol(bool connectToProtocol) internal {
        _cube3Storage().shouldCheckFnProtection = connectToProtocol;
        emit Cube3ProtocolConnectionUpdated(connectToProtocol);
    }

    // TODO: test the correct slot is returned
    /// @dev Convenience function that returns a storage pointer to CUBE3 protection storage.
    function _cube3Storage() internal pure returns (ProtectedStorage storage cube3Storage) {
        assembly {
            cube3Storage.slot := CUBE3_PROTECTED_STORAGE_LOCATION
        }
    }

    /// @dev Helper function as a non-payable function cannot read msg.value in the modifier.
    /// Will not clash with `_msgValue` in the event that the derived contract inherits {Context}.
    function _getMsgValue() internal view returns (uint256) {
        return msg.value;
    }
}
