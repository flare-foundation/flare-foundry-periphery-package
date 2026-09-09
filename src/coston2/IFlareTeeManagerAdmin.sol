// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import { IExtensionManager } from "./IExtensionManager.sol";
import { IExtensionGovernance } from "./IExtensionGovernance.sol";
import { IOwnerAllowlist } from "./IOwnerAllowlist.sol";
import { IExternalAddresses } from "./IExternalAddresses.sol";
import { IDiamondLoupe } from "./diamond/interfaces/IDiamondLoupe.sol";

/**
 * Periphery-defined composition of published diamond facets.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IFlareTeeManagerAdmin is
    IExtensionManager,
    IExtensionGovernance,
    IOwnerAllowlist,
    IExternalAddresses,
    IDiamondLoupe
{
}
