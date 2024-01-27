// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Constants} from "../utils/Constants.sol";
contract MockRouter is Constants {

    bool public registrationShouldSucceed;
    bool public routingShouldSucceed;



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

    function initiateIntegrationRegistration(address admin) external view returns (bool) {
        // prevent compiler warnings
        (admin);
        if (!registrationShouldSucceed) {
            return false;
        }

        return true;
    }
    function routeToModule(
        address integrationMsgSender,
        uint256 integrationMsgValue,
        bytes calldata integrationCalldata
    ) external view returns (bytes32) {
        // prevent compiler warnings
        (integrationMsgSender);
        (integrationMsgValue);
        (integrationCalldata);

        if (!routingShouldSucceed) {
            revert("MockRouter: routing failed");
        }

        return PROCEED_WITH_CALL;
    }
}