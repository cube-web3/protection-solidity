# CUBE3 Protection

This repository contains the smart contract abstractions required to integrate with the [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity). Please review the Protocol's documentation to ensure you understand the relationship between an integration contract, created by
inheriting from the abstract contracts provided in this repository, and the CUBE3 Core Protocol.

In-depth documentation is available at [docs.cube3.io](https://docs.cube3.io).

## Installation

### Foundry

```bash
forge install cube-web3/protection-solidity
```

Next, add the CUBE3 contracts to your `remappings.txt` file:

```
@cube3/=lib/cube-web3/protection-solidity
```

### Steps required to create an integration

Creating an "integration" refers to the process of deploying a contract that inherits from the abstract contracts provided in this repository and completing registration with the CUBE3 protocol. An integration has access to the functionality provided by the CUBE3 Core Protocol's security modules. Enabling access to these modules requires the addition of the `cube3Protected` modifier to the functions you wish to protect. The process of utilizing the services offered by CUBE3 is as follows:

-   Inherit one of the abstract contracts provided in this repository.
-   Decorate desired functions with the `cube3Protected` modifier.
-   Deploy your contract and provide the `integrationAdmin` address to the constructor. See [Security Considerations](#Security Considerations) section for more details about the admin role.
-   Visit [cube3.ai](https://cube3.ai) to sign up for RASP and complete the registration of your integration.
-   Enable function protection for your functions.
-   Add the CUBE3 SDK to your dDapp and provide your users with the `cube3Payload`, required by the modifier, when submitting transactions on-chain.

## Security considerations

Function protection logic is handled in the abstract [IntegrationManagement](https://github.com/cube-web3/protocol-core-solidity/blob/main/src/abstracts/IntegrationManagement.sol) contract inherited by the CUBE3 Router . The protection status of functions decorated with the `cube3Protected` modifier can only be updated by this integration's admin account.

## Registration

## Usage

## Testing

To run the tests, you will need to install the dependencies:

```bash
forge install
```

Once dependencies are installed, you can run the test suite via:

```bash
forge test -vvv
```

## EVM Compatibility

The [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity) will be deployed on multiple EVM-compatible chains. For this reason, the `solc` version of the protocol is fixed to `0.8.19` to account for the introduction of the `PUSH0` opcode, which not all chains support. You can read more [here](https://soliditylang.org/blog/2023/05/10/solidity-0.8.20-release-announcement/) about the changes introduced in the Shanghai upgrade. To avoid version conflicts and adding dependencies to this repository, tests covering proxies and the upgradeable version of the protection contracts import `Openzeppelin` contracts from the `release-v4.9` branch that are included in the `test/external_libs/openzeppelin` directory.

## FAQ

### Which contract should I be importing?

Proxy implementation's should utilize the `Cube3ProtectionUpgradeable` contract, while non-upgradeable implementations should inherit the `Cube3Protection` contract.

### Do I have to start using CUBE3 from the moment I deploy my contract?

No, you can start using CUBE3's services at any time after deploying your contract. The `cube3Protected` modifier will check the function protection status once registration has been completed.

### What happens if I stop using CUBE3's services after I've deployed my contract?

You have two options for disconnecting from CUBE3's services:

1. If your contract has an access control mechanism, you can call the `{ProtectionBase-_updateShouldUseProtocol}` function from within a restricted function, which will prevent any calls to the CUBE3 protocol being made. Note, even once the connection has been severed, an `SLOAD` operation is still required for retrieving the flag from storage on every function call.

2. Disabling function protection for all functions via the CUBE3 Protocol's Router. This will
