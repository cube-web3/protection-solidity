// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <0.9.0;

/// @notice Abstract contract containing events emitted by the Protection contracts.
abstract contract Events {
    // Emitted in {_baseInitProtection} when the router address is updated.
    event Cube3ProtectionRouterUpdated(address newRouter);

    // Emitted in {_baseInitProtection} when the protocol connection is updated.
    event Cube3ProtocolConnectionUpdated(bool connectionEstablished);

    // Emitted when a generic function call succeeds.
    event CallSucceeded();

    // Emitted when an integration is deployed.
    event Cube3IntegrationDeployed(
        address indexed integrationAdmin,
        bool enabledByDefault
    );
}
