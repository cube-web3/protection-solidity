# CUBE3 Protection

This repository contains the smart contract abstractions required to integrate with the [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity). Please review the Protocol's documentation to ensure you understand the relationship between an integration contract, created by
inheriting from the abstract contracts provided in this repository, and the Core Protocol.

In-depth documentation of the services offered by CUBE3 is available at [docs.cube3.io](https://docs.cube3.io).

## Installation

**Important note:** The CUBE3 Protection contracts do not have any external dependencies. However, Openzeppelin libraries are used in testing.

### Foundry

```bash
forge install cube-web3/protection-solidity
```

Next, add the CUBE3 contracts to your `remappings.txt` file:

```
@cube3/=lib/cube-web3/protection-solidity/src/
```

### NPM / Yarn

```bash
npm install @cube-web3/protection-solidity
yarn install @cube-web3/protection-solidity
```

### Steps required to create an integration

Creating an "integration" refers to the process of deploying a contract that inherits from the either of the abstract contracts provided in this repository (`Cube3Protection` or `Cube3ProtectionUpgradeable`) and completing registration on-chain with the CUBE3 protocol. An integration has access to the functionality provided by the CUBE3 Core Protocol's security modules. Enabling access to these modules requires the addition of the `cube3Protected` modifier to the functions you wish to protect.

The process of utilizing the services offered by CUBE3 is as follows:

-   Inherit one of the abstract contracts provided in this repository.
-   Decorate desired functions with the `cube3Protected` modifier, or include the `_assertProtectWhenConnected` at the top of the function, and ensure that the function signature's last argument is `bytes calldata cube3Payload`.
-   Deploy your contract and provide the `integrationAdmin` address to the constructor. See [Security Considerations](#Security Considerations) section for more details about the admin account's permissions and responsibilities.
-   Visit [cube3.ai](https://cube3.ai) to sign up for RASP and complete the registration of your integration by calling `registerIntegrationWithCube3(...)` on the CUBE3 Protocol's Router contract.
-   Enable function protection for your functions via the `updateFunctionProtectionStatus(...)` on the CUBE3 Protocol's Router contract. (Note: this function is only callable by the integration's admin account.)
-   Add the CUBE3 SDK to your dDapp and provide your users with the `cube3Payload`, required by the modifier, when submitting transactions on-chain.

## Security considerations

Function protection logic is handled in the [CUBE3 Protocol's Router](https://github.com/cube-web3/protocol-core-solidity/blob/main/src/abstracts/IntegrationManagement.sol) contract inherited by the CUBE3 Router . The protection status of functions decorated with the `cube3Protected` modifier can only be updated by this integration's admin account.

## Usage

Inherit from either `Cube3Protection` or `Cube3ProtectionUpgradeable` and decorate the functions you wish to protect with the `cube3Protected` modifier. The `cube3Protected` modifier will check the protection status of the function and revert the transaction if the function is not protected.

#### Standalone example

##### Using the modifier

```solidity
contract MyContract is Cube3Protection {

    constructor(address _router)
     Cube3Protection(
      _router,
      msg.sender, // deployer becomes the integrationAdmin
      true // enable the connection to the protocol
     ) {}

    function myFunction(...args, bytes calldata cube3Payload) external cube3Protected(cube3Payload) {
        // Your logic here
    }
}
```

##### Using the inline assertion

```solidity
contract MyContract is Cube3Protection {

    constructor(address _router)
     Cube3Protection(
      _router,
      msg.sender, // deployer becomes the integrationAdmin
      true // enable the connection to the protocol
     ) {}

    function myFunction(...args, bytes calldata cube3Payload) external  {
        _assertProtectWhenConnected(cube3Payload)
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

To complete registration of an integration on-chain, a `registrarToken` is required. This can be generated when signing up for [CUBE3.ai services](https://cube3.ai).

Below is an example of calling the `registerIntegrationWithCube3` function on the CUBE3 Router.

```typescript
import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const routerABI = [
    /* ABI of the CUBE3 Router */
];
const contractAddress = "/* Your smart contract address */";
const cube3RouterAddress = "/* CUBE3 Router Address */";
const securityAdminPrivateKey = process.env.SECURITY_ADMIN_PVT_KEY;
const provider = new ethers.providers.JsonRpcProvider("/* Your Ethereum node URL */");

// This should be the same account set as the `integrationAdmin` when deploying the integration
const wallet = new ethers.Wallet(securityAdminPrivateKey, provider);

const registrarToken = process.env.REGISTRAR_TOKEN; // acquired from CUBE3

async function callRegisterIntegrationWithCube3() {
    const contract = new ethers.Contract(cube3RouterAddress, routerABI, wallet);
    const enabledByDefaultFnSelectors: bytes4[] = [];

    try {
        const tx = await contract.registerIntegrationWithCube3(
            contractAddress,
            registrarToken,
            enabledByDefaultFnSelectors
        );
        const receipt = await tx.wait();
        console.log("Transaction successful:", receipt);
    } catch (error) {
        console.error("Transaction failed:", error);
    }
}

await callRegisterIntegrationWithCube3();
```

## Updating function protection

```typescript
import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const routerABI = [
    /* ABI of the CUBE3 Router */
];
const contractAddress = "/* Your smart contract address */";
const cube3RouterAddress = "/* CUBE3 Router Address */";
const integrationAdminPrivateKey = process.env.INTEGRATION_ADMIN_PVT_KEY;
const provider = new ethers.providers.JsonRpcProvider("/* Your Ethereum node URL */");

// This should be the same account set as the `integrationAdmin` when deploying the integration
const adminSigner = new ethers.Wallet(integrationAdminPrivateKey, provider);

// Create contract instance
const routerContract = new ethers.Contract(routerAddress, routerABI, adminSigner);

// Define the FunctionProtectionStatusUpdate struct
interface FunctionProtectionStatusUpdate {
    fnSelector: string;
    protectionEnabled: boolean;
}

const updates: FunctionProtectionStatusUpdate[] = [
    {
        fnSelector: "0x12345678",
        protectionEnabled: true,
    },
    {
        fnSelector: "0x87654321",
        protectionEnabled: false,
    },
];

(async () => {
    try {
        // Call the updateFunctionProtectionStatus function
        const tx = await routerContract.updateFunctionProtectionStatus(integrationAddress, updates);

        // Wait for the transaction to be mined
        const receipt = await tx.wait();

        console.log("Transaction successful!");
        console.log("Transaction hash:", receipt.hash);
        console.log("Block number:", receipt.blockNumber);
    } catch (error) {
        console.error("Error updating function protection status:", error);
    }
})();
```

## Connection to the CUBE3 protocol

### Checking the connection status

The CUBE3 payload will only be forwarded to the Router if the connection to the Router is enabled. The can be checked at any time by calling the `connectedToCUBE3()` function on your contract. When this function returns `true`, the payload will be forwarded to the Router. If, and only if, function protection is enabled for the respective function from the top-level call, will the payload be forwarded to the security module designated in the routing portion of the payload.

```typescript
// example TS function checking an integration's connection to the CUBE3 protocol
async function checkConnection(): Promise<boolean> {
    return await myContract.connectedToCUBE3();
}
```

### Updating the connection status

Connection to the CUBE3 Protocol can be enabled/disabled, however updating the status **MUST** only be done via an `external`/`public` function with access control restrictions. The connection status is updated via the `internal _updateShouldUseProtocol(...)` inherited from `ProtectionBase.sol`. If this function is exposed without access control, any bad actor can disable the protections offered by the CUBE3 Protocol.

```solidity

/// @notice EXAMPLE OF A CORRECT IMPLEMENTATION
/// @dev Protected by access control
function updateCube3Connection(bool shouldConnect) external onlyOwner {
    _updateShouldUseProtocol(shouldConnect);
}

/// @notice INCORRECT IMPLEMENTATION
/// @dev DANGER - any account can disconnect from CUBE3
function updateCube3Connection(bool shouldConnect) external {
    _updateShouldUseProtocol(shouldConnect);
}
```

## Testing

To run the tests, you will need to install the dependencies:

```bash
forge install
```

Once dependencies are installed, you can run the test suite via:

```bash
forge test -vvv
```

More comprehensive integration tests that utilize the protocol's functionality are available in the [Core Protocol Repo](https://github.com/cube-web3/protocol-core-solidity/tree/main/test/foundry/integration).

##

## EVM Compatibility

The [CUBE3 Core Protocol](https://github.com/cube-web3/protocol-core-solidity) will be deployed on multiple EVM-compatible chains. Not all EVM chains support the `PUSH0` opcode introduced in the `Shanghai` upgrade. You can read more [here](https://soliditylang.org/blog/2023/05/10/solidity-0.8.20-release-announcement/) about the changes introduced in Solidity `0.8.20`. To deploy on a chain that does not support the `PUSH0` opcode, you will need to compile the contracts with the `--evm-version` flag set to `paris`. For example:

```bash
forge build --evm-version paris
```

## FAQ

### Which contract should I be importing?

Upgradeable contracts, or contracts that utilize a proxy pattern, should inherit the `Cube3ProtectionUpgradeable` contract, while non-upgradeable implementations should inherit the `Cube3Protection` contract. Both contracts inherit their logic from the `ProtectionBase` contract, with the primary difference being how the contracts are initialized.

### Do I have to start using CUBE3 from the moment I deploy my contract?

No, you can start using CUBE3's services at any time after deploying your contract. The `cube3Protected` modifier, and inline `_assertProtectWhenConnected` function, will check the function protection status once registration has been completed. Even after registering, you can leave protection status for all functions disabled until you are ready to start using CUBE3's services.

### What happens if I stop using CUBE3's services?

You have two options for disconnecting from CUBE3's services:

1. If your contract has an access control mechanism, you can call the `{ProtectionBase-_updateShouldUseProtocol}` function from within a restricted function, which will prevent any calls to the CUBE3 protocol being made. Note, even once the connection has been severed, an `SLOAD` operation is still required for retrieving the flag from storage on every function call.

2. Disabling function protection for all functions via the CUBE3 Protocol's Router. This will

### What is the contract size of the inheritable contracts?

The `Cube3Protection` contract is around ~1.55kb.

### Should I be using the modifier, or the inline assertion, or both?

For any function that you wish to protect, you should us either the modifier **OR** the inline assertion, **BUT NOT** both.

The considerations for choosing either are as follows:

**Modifiers vs. Inline Assertions:**

-   Modifiers: Modifiers are a way to reuse code before and/or after a function's execution. When a modifier is used, Solidity effectively copies the modifier's code into the function's body at compile time. This can lead to increased bytecode size, especially if the modifier is used excessively.

-   Inline Assertions: Inline assertions (e.g., require statements) are placed directly within the function body. They do not increase the bytecode size as much as modifiers do because they are not duplicated across multiple functions.

**Code Size Considerations:**

Solidity has a maximum contract size limit (24KB).
By using inline assertions instead of modifiers, you reduce the risk of hitting the bytecode size limit because the assertion logic is not duplicated.

By calling the internal function within the function body, it results in a `JUMP` opcode, which is more efficient compared to the duplication of modifier logic whereby the same code is included in the bytecode multiple times.
