// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/// @notice Abstract contract containing events emitted by the Protection contracts.
abstract contract Events {

    event Cube3ProtectionRouterUpdated(address newRouter);
    
    event Cube3ProtocolConnectionUpdated(bool connectionEstablished);
    
}