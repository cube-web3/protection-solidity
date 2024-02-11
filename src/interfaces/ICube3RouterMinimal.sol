// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.8.24;

/// @title ICube3RouterMinimal
/// @notice Minimal interface for interacting with the CUBE3 Router.
/// @dev This interface omits all function signatures for functions that are not called
/// directly by this integration contract.
interface ICube3RouterMinimal {
    /// @notice Initiates the registration of a new integration.
    /// @dev Called from within the constructor during deployment.
    /// @param integrationAdmin The account to grant elevated privileges to on the CUBE3 Router.
    /// This account will be able to update the protection status of functions decorated with the
    /// {cube3Protected} modifier. Admin priviliges can be transferred to a new account via the Router.
    /// @return Returns true if the registration was successful.
    function initiateIntegrationRegistration(address admin) external returns (bool);

    /// @notice Routes the top-level calldata, including the `cube3Payload`, to the CUBE3 Router.
    /// @dev Acts like an assertion. The call Protocol will revert the transaction if the data contained in the
    /// `cube3Payload` is invalid or does not meet the conditions of the security module being utilized. No Ether
    /// is transferred in this call.
    /// @param integrationMsgSender The `msg.sender` of the top-level call.
    /// @param integrationMsgValue The `msg.value` of the top-level call.
    /// @return The hashed representation of PROCEED_WITH_CALL if the module call succeeds, protection for the function
    /// is disabled, or this integration's registration status is disabled. Otherwise, the call will revert.
    function routeToModule(
        address integrationMsgSender,
        uint256 integrationMsgValue,
        bytes calldata integrationCalldata
    )
        external
        returns (bytes32);
}
