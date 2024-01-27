# CUBE3 Protection

This repository contains the abstract smart contracts required to integrate with the [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity). Please review the Protocol's readme to ensure you understand the relationship between

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

### Hardhat

```bash

```

### Steps required to create an integration

- Inherit one of the abstract contracts provided in this repository.
- Decorate desired functions with the `cube3Protected` modifier.
- Deploy your contract and provide the `integrationAdmin` address to the constructor. See [Security Considerations](#Security Considerations) section for more details about the admin role.
- Visit [cube3.ai](https://cube3.ai) to sign up for RASP and register your integration.
- Enable function protection for your functions.
- Add the CUBE3 SDK to your dDapp.

## Security considerations

Function protection logic is handled in the [CUBE3 Router](). The protection status of functions decorated with the `cube3Protected` modifier can only be updated by this integration's admin.

## Registration

## Usage

- Note about mutable vs immutable and needing to have access control for mutable version to make sense
- Need to include router at deployment

## Testing

The [CUBE3 Core Protocol]() will be deployed on multiple EVM-compatible chains. For this reason, the `solc` version of the protocol is fixed to `0.8.19` to account for the introduction of the `PUSH0` opcode, which not all chains support. You can read more [here](https://soliditylang.org/blog/2023/05/10/solidity-0.8.20-release-announcement/) about the changes introduced in the Shanghai upgrade. To avoid version conflicts and adding dependencies to this repository, tests covering proxies and the upgradeable version of the protection contracts import `Openzeppelin` contracts from the `release-v4.9` branch that are included in the `test/external_libs/openzeppelin` directory.

## FAQ

### Which contract should I be importing?

### What happens if I stop using CUBE3's services after I've deployed my contract?

### Do I have to start using CUBE3 from the moment I deploy my contract?
