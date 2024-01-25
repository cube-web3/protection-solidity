// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouter} from "./interfaces/IRouter.sol";

abstract contract ProtectionBase {
    // Hashed return value from the router indicating the call is safe to proceed.
    bytes32 private constant PROCEED_WITH_CALL = keccak256("PROCEED_WITH_CALL");

    // keccak256(abi.encode(uint256(keccak256("cube3.protected.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant CUBE3_PROTECTED_STORAGE_LOCATION =
        0xa8b0d2f2aabfdf699f882125beda6a65d773fc80142b8218dc795eaaa2eeea00;


    event Cube3ProtectionRouterUpdated(address newRouter);
    
    event Cube3ProtocolConnectionUpdated(bool shouldUseCube3);

    /// @custom:storage-location erc7201:cube3.protected.storage
    struct ProtectedStorage {
        address router;
        bool shouldUseCube3;
    }

    modifier cube3Protected(bytes calldata cube3Payload) {
        // Read both the router and shouldUseCube3 from storage in a single SLOAD.
        ProtectedStorage memory protectedStorage = _protectedStorage();
        if (protectedStorage.shouldUseCube3) {
            _assertShouldProceedWithCall(cube3Payload);
        }
        _;
    }

    /// @dev `_payload` isn't used, but is kept a an argument to force the modifier to accept the argument to
    /// remind the implementer to add the payload as the last argument in the function signature.
    function _assertShouldProceedWithCall(bytes calldata _payload) internal {
        // prevent compiler warnings.
        (_payload);

        // Packs the top-level function call context to be sent to the router to be evaluated.
        bytes memory routerCalldata =
            abi.encodeWithSelector(IRouter.routeToModule.selector, msg.sender, _getMsgValue(), msg.data);
        (bool success, bytes memory returnOrRevertData) = (_protectedStorage().router).call(routerCalldata);

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

     /**

     * @dev Called by the derived contract's initializer or constructor to set the router address and integration admin.
     * @dev Passing the zero address as the `integrationAdmin` will set the admin to the deployer by default.
     * @param router The address of the CUBE3 Router contract.
     * @param integrationAdmin The address of the integration admin. Set and managed by the CUBE3 Router.
     * @param enabledByDefault If set to true, the connection to the CUBE3 core protocol will be established by default.  
     */
    function _baseInitProtection(address router, address integrationAdmin, bool enabledByDefault) internal {
        require(router != address(0), "Invalid: Router ZeroAddress");

        // If no integration admin is provided, use the deployer as the integration admin by default.
        if(integrationAdmin == address(0)){
         integrationAdmin = msg.sender;
        }

        // Access the storage pointer declared in ProtectionBase.sol
        ProtectedStorage storage protectedStorage = _protectedStorage();
        
        // Set the router address.
        protectedStorage.router = router;
        emit Cube3ProtectionRouterUpdated(router);

        // Enable/disable the connection to the CUBE3 core protocol.
        protectedStorage.shouldUseCube3 = enabledByDefault;
        emit Cube3ProtocolConnectionUpdated(enabledByDefault);

        // TODO: will this succeed if the router address is wrong?
        // Pre-register this integration with the router and set the integration admin address. Serves the dual purpose
        // of validating that the correct router address was passed to the constructor.
        bool preRegistrationSucceeded = IRouter(router).initiateIntegrationRegistration(integrationAdmin);
        require(preRegistrationSucceeded, "pre-registration failed");
    }

    /// @dev WARNING: This MUST only be called within an external/public fn by an account with elevated privileges.
    /// @dev If the derived contract has no access control, this function should not be exposed and the connection
    ///      to the protocol is locked at the time of deployment.
    function _warning_updateShouldUseCube3(bool shouldUseCube3) internal {
        ProtectedStorage storage protectedStorage = _protectedStorage();
        protectedStorage.shouldUseCube3 = shouldUseCube3;
        emit Cube3ProtocolConnectionUpdated(shouldUseCube3);
    }

    function _protectedStorage() internal pure returns (ProtectedStorage storage cube3Storage) {
        assembly {
            cube3Storage.slot := CUBE3_PROTECTED_STORAGE_LOCATION
        }
    }

    /// @dev Helper function as a non-payable function cannot read msg.value in the modifier.
    /// @dev Will not clash with `_msgValue` in the event that the derived contract inherits {Context}.
    function _getMsgValue() private view returns (uint256) {
        return msg.value;
    }
}