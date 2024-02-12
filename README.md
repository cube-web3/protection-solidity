# CUBE3 Protection

This repository contains the smart contract abstractions required to integrate with the [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity). Please review the Protocol's documentation to ensure you understand the relationship between an integration contract, created by
inheriting from the abstract contracts provided in this repository, and the Core Protocol.

In-depth documentation of the services offered by CUBE3 is available at [docs.cube3.io](https://docs.cube3.io).

## Installation

### Foundry

```bash
forge install cube-web3/protection-solidity
```

Next, add the CUBE3 contracts to your `remappings.txt` file:

```
@cube3/=lib/cube-web3/protection-solidity/src/
```

### Steps required to create an integration

Creating an "integration" refers to the process of deploying a contract that inherits from the either of the abstract contracts provided in this repository (`Cube3Protection` or `Cube3ProtectionUpgradeable`) and completing registration on-chain with the CUBE3 protocol. An integration has access to the functionality provided by the CUBE3 Core Protocol's security modules. Enabling access to these modules requires the addition of the `cube3Protected` modifier to the functions you wish to protect. The process of utilizing the services offered by CUBE3 is as follows:

-   Inherit one of the abstract contracts provided in this repository.
-   Decorate desired functions with the `cube3Protected` modifier.
-   Deploy your contract and provide the `integrationAdmin` address to the constructor. See [Security Considerations](#Security Considerations) section for more details about the admin role.
-   Visit [cube3.ai](https://cube3.ai) to sign up for RASP and complete the registration of your integration by calling `registerIntegrationWithCube3(...)` on the CUBE3 Protocol's Router contract.
-   Enable function protection for your functions via the `updateFunctionProtectionStatus(...)` on the CUBE3 Protocol's Router contract. (Note: this function is only callable by the integration's admin account.)
-   Add the CUBE3 SDK to your dDapp and provide your users with the `cube3Payload`, required by the modifier, when submitting transactions on-chain.

## Security considerations

Function protection logic is handled in the [CUBE3 Protocol's Router](https://github.com/cube-web3/protocol-core-solidity/blob/main/src/abstracts/IntegrationManagement.sol) contract inherited by the CUBE3 Router . The protection status of functions decorated with the `cube3Protected` modifier can only be updated by this integration's admin account.

## Usage

Inherit from either `Cube3Protection` or `Cube3ProtectionUpgradeable` and decorate the functions you wish to protect with the `cube3Protected` modifier. The `cube3Protected` modifier will check the protection status of the function and revert the transaction if the function is not protected.

#### Standalone example

```solidity
contract MyContract is Cube3Protection {

    constructor(address _router)
     Cube3Protection(
      _router,
      msg.sender, // deployer becomes the integrationAdmin
      true // enable the connection to the protocol
     ) {}

    function myFunction(...args, cube3Payload) external cube3Protected(cube3Payload) {
        // Your logic here
    }
}
```

#### Proxy example

```solidity
contract MyContractUpgradeable is Cube3ProtectionUpgradeable, UUPSUpgradeable, OwnableUpgradeable {

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address router, address admin, bool checkProtection) initializer public {

       // In this scenario, the contract owner is the same account as the integration's admin, which
       // has privileged access to the router.
        __Cube3ProtectionUpgradeable_init(router, admin, checkProtection);
        __Ownable_init(admin);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function myFunction(...args, bytes calldata cube3Payload) public cube3Protected(cube3Payload) {
      // Your logic here
    }

}
```

## Registration

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

The [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity) will be deployed on multiple EVM-compatible chains. Not all EVM chains support the `PUSH0` opcode introduced in the `Shanghai` upgrade. You can read more [here](https://soliditylang.org/blog/2023/05/10/solidity-0.8.20-release-announcement/) about the changes introduced in Solidity `0.8.20`. To deploy on a chain that does not support the `PUSH0` opcode, you will need to compile the contracts with the `--evm-version` flag set to `paris`. For example:

```bash
forge build --evm-version paris
```

## FAQ

### Which contract should I be importing?

Upgrade contracts, or contracts that utilize a proxy pattern, should inherit the `Cube3ProtectionUpgradeable` contract, while non-upgradeable implementations should inherit the `Cube3Protection` contract. Both contracts inherit their logic from the `ProtectionBase` contract, with the primary difference being how the contracts are initialized.

### Do I have to start using CUBE3 from the moment I deploy my contract?

No, you can start using CUBE3's services at any time after deploying your contract. The `cube3Protected` modifier will check the function protection status once registration has been completed. Even after registering, you can leave protection status for all functions disabled until you are ready to start using CUBE3's services.

### What happens if I stop using CUBE3's services?

You have two options for disconnecting from CUBE3's services:

1. If your contract has an access control mechanism, you can call the `{ProtectionBase-_updateShouldUseProtocol}` function from within a restricted function, which will prevent any calls to the CUBE3 protocol being made. Note, even once the connection has been severed, an `SLOAD` operation is still required for retrieving the flag from storage on every function call.

2. Disabling function protection for all functions via the CUBE3 Protocol's Router. This will

### What is the contract size of the inheritable contracts?

The `ProtectionBase` contract is around ~2kb.
