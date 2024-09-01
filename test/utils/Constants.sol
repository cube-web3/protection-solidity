// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

abstract contract Constants {
    enum RouterRevertReason {
        NON_EXISTENT_MODULE,
        MODULE_CALL_FAILED,
        INVALID_MODULE_RESPONSE
    }

    // Returned by the router if the module call succeeds, the integration is not registered, the protocol is paused, or
    // the function is not protected.
    bytes32 internal constant PROCEED_WITH_CALL = keccak256("CUBE3_PROCEED_WITH_CALL");

    // Returned by the router when the pre-registration of the integration is successful.
    bytes32 internal constant PRE_REGISTRATION_SUCCEEDED = keccak256("CUBE3_PRE_REGISTRATION_SUCCEEDED");
}
