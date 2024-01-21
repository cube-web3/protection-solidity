// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {IRouter} from "../interfaces/IRouter.sol";
import {ProtectionBase} from "../ProtectionBase.sol";

/*//////////////////////////////////////////////////////////////
            UPGRADEABLE VERSION
//////////////////////////////////////////////////////////////*/

/// @dev The upgradeable version follows ERC-7201 to prevent storage collisions in the event of an upgrade.
/// @dev The initialize functions should be caleld in the derived contract's initializer.

abstract contract Cube3ProtectionUpgradeable is ProtectionBase {
    // keccak256(abi.encode(uint256(keccak256("cube3.protected.storage")) - 1)) & ~bytes32(uint256(0xff));
    bytes32 private constant CUBE3_PROTECTED_STORAGE_LOCATION =
        0xa8b0d2f2aabfdf699f882125beda6a65d773fc80142b8218dc795eaaa2eeea00;

    /// @custom:storage-location erc7201:cube3.protected.storage
    struct ProtectedStorage {
        address router;
    }

    modifier cube3Protected(bytes calldata cube3Payload) {
        _assertShouldProceedWithCall(_protectedStorage().router, cube3Payload);
        _;
    }

    /// @dev The `integrationAdmin` can be considered the owner of the this contract, from the CUBE3 protocol's perspective,
    ///      and is the account that will be permissioned to complete the registration with the protocol and enable/disable
    ///      protection for the functions decorated with the {cube3Protected} modifier.
    /// @dev MUST be called in the derived contract's initializer.
    function __Cube3ProtectionUpgradeable_init(address _router, address _integrationAdmin) internal {
        __Cube3ProtectionUpgradeable_init_unchained(_router, _integrationAdmin);
    }

    function __Cube3ProtectionUpgradeable_init_unchained(address _router, address _integrationAdmin) private {
        require(_integrationAdmin != address(0), "TODO: invalid admin");
        require(_router != address(0), "TODO: invalid router");
        ProtectedStorage storage protectedStorage = _protectedStorage();
        protectedStorage.router = _router;

        // TODO: will this succeed if the router address is wrong? TEST
        //   bytes memory preRegisterCalldata = abi.encodeWithSignature("initiateIntegrationRegistration(admin)", integrationAdmin);
        //   (bool success, ) = cube3Router.call(preRegisterCalldata);
        bool preRegistrationSucceeded = IRouter(_router).initiateIntegrationRegistration(_integrationAdmin);
        require(preRegistrationSucceeded, "pre-registration failed");
    }

    function _protectedStorage() internal pure returns (ProtectedStorage storage cubeStorage) {
        assembly {
            cubeStorage.slot := CUBE3_PROTECTED_STORAGE_LOCATION
        }
    }
}
