// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.9.0;

import { Constants } from "../utils/Constants.sol";

/// @notice Mock router contract that emulates the functionality of the CUBE3 router.
contract MockRouter is Constants {
    bool public registrationShouldSucceed;
    bool public routingShouldSucceed;
    address public msgSender;
    uint256 public msgValue;
    bytes public msgData;

    mapping(address => address) public mockIntegrationAdmin;

    constructor(bool _registrationShouldSucceed, bool _routingShouldSucceed) {
        registrationShouldSucceed = _registrationShouldSucceed;
        routingShouldSucceed = _routingShouldSucceed;
    }

    function updateRegistrationShouldSucceed(bool _registrationShouldSucceed) external {
        registrationShouldSucceed = _registrationShouldSucceed;
    }

    function updateRoutingShouldSucceed(bool _routingShouldSucceed) external {
        routingShouldSucceed = _routingShouldSucceed;
    }

    function initiateIntegrationRegistration(address admin) external returns (bytes32) {
        // prevent compiler warnings

        if (!registrationShouldSucceed) {
            return keccak256("FAILED");
        }
        mockIntegrationAdmin[msg.sender] = admin;

        return PRE_REGISTRATION_SUCCEEDED;
    }

    function routeToModule(
        address integrationMsgSender,
        uint256 integrationMsgValue,
        bytes calldata integrationCalldata
    )
        external
        returns (bytes32)
    {
        msgSender = integrationMsgSender;
        msgValue = integrationMsgValue;
        msgData = integrationCalldata;

        if (!routingShouldSucceed) {
            revert("MockRouter: routing failed");
        }

        return PROCEED_WITH_CALL;
    }
}
