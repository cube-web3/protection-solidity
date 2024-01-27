// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


abstract contract Constants {

    enum RouterRevertReason {
      NON_EXISTENT_MODULE,
      MODULE_CALL_FAILED,
      INVALID_MODULE_RESPONSE
    }

     // Returned by the router if the module call succeeds, 
     // the integration is not registered, the protocol is paused, or 
     // the function is not protected.
    bytes32 public constant PROCEED_WITH_CALL = keccak256("PROCEED_WITH_CALL");
}