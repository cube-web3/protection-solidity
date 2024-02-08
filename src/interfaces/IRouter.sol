// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 < 0.8.24;

interface IRouter {
    // TODO: NATSPEC
    function initiateIntegrationRegistration(address admin) external returns (bool);
    function routeToModule(
        address integrationMsgSender,
        uint256 integrationMsgValue,
        bytes calldata integrationCalldata
    )
        external
        returns (bytes32);
}
