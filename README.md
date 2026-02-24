# Flare periphery package for Foundry

This package contains a collection of smart contract interfaces deployed on the **Flare**, Coston2 (test network for Flare), **Songbird** and Coston (test network for Songbird) networks.

The intention of this package is to provide a set of **interfaces** for easier integration and development of smart contracts on Flare based networks.
Interfaces in the most recent version of this package are the same as the ones deployed on the networks. This package exposes all public and most of the internal interfaces but **does not** expose any of the implementations. If you want to access the implementations, you can use the official [Flare smart contracts repo](https://github.com/flare-foundation/flare-smart-contracts-v2).

Basic familiarity with the Flare network and EVM is assumed for use. For more information, please refer to the [Flare Developer Hub](https://dev.flare.network/). For a guided introduction to smart contract development on Flare, see [Getting Started with Flare](https://dev.flare.network/network/getting-started).

## Installation

Install the package using Forge Soldeer:

```sh
forge soldeer install flare-periphery~<version>
```

This will add the package to your `soldeer.lock` and make it available for import under the `flare-periphery/` prefix.

## Package structure

Each network has its own folder inside `src/`. All interfaces are placed flat within the respective network folder.

```
src/
├── coston
├── coston2
├── flare
└── songbird
```

> **Note:** The `coston2` folder also includes Smart Accounts interfaces.

## Example usages

### Using FTSO v2 feeds in your contract

To read FTSO v2 feed data on Flare, import `IFtsoV2` and the relay interfaces:

```solidity
import { IFtsoV2 } from "flare-periphery/src/flare/IFtsoV2.sol";
import { IRelay } from "flare-periphery/src/flare/IRelay.sol";
```

For Coston2 (testnet):

```solidity
import { IFtsoV2 } from "flare-periphery/src/coston2/IFtsoV2.sol";
```

### Using the Flare Data Connector (FDC)

To verify attestations using the FDC:

```solidity
import { IFdcHub } from "flare-periphery/src/flare/IFdcHub.sol";
import { IFdcVerification } from "flare-periphery/src/flare/IFdcVerification.sol";
```

### Using FAssets interfaces

FAsset interfaces are available on all networks:

```solidity
import { IAssetManager } from "flare-periphery/src/flare/IAssetManager.sol";
import { IFAsset } from "flare-periphery/src/flare/IFAsset.sol";
```

### Using the ContractRegistry

Each network folder includes a generated `ContractRegistry` Solidity library with on-chain addresses for all registered contracts:

```solidity
import { ContractRegistry } from "flare-periphery/src/flare/ContractRegistry.sol";
```

------

**You've got the tools, turn on your imagination and go build something awesome!**

If you find any mistakes or have suggestions, please open an issue or contact us directly.

**Package is provided as is, without any warranty.**
