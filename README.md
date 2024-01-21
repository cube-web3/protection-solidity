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
