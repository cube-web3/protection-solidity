// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouter} from "./interfaces/IRouter.sol";

abstract contract ProtectionBase {
    bytes32 private constant PROCEED_WITH_CALL = keccak256("PROCEED_WITH_CALL");

    /// @dev `_payload` isn't used, but is kept a an argument to force the modifier to accept the argument to
    /// remind the implementer to add the payload as the last argument in the function signature.
    function _assertShouldProceedWithCall(address _router, bytes calldata _payload) internal {
        (_payload); // prevent compiler warnins.

        // forwards the called function's calldata, including the secure payload, to the router to be assessed
        bytes memory routerCalldata =
            abi.encodeWithSelector(IRouter.routeToModule.selector, msg.sender, _getMsgValue(), msg.data);
        (bool success, bytes memory returnOrRevertData) = _router.call(routerCalldata);

        // TODO: handle this revert/success data
        //   if (success || returnOrRevertData.length != 4) {
        if (success && returnOrRevertData.length == 32) {
            bytes32 response = abi.decode(returnOrRevertData, (bytes32));
            if (response != PROCEED_WITH_CALL) {
                revert("TODO not safe");
            }
        } else {
            revert("TODO Failed");
        }
    }

    /// @dev Helper function as a non-payable function cannot read msg.value in the modifier.
    /// @dev Will not clash with `_msgValue` in the event that the derived contract inherits {Context}.
    function _getMsgValue() private view returns (uint256) {
        return msg.value;
    }
}