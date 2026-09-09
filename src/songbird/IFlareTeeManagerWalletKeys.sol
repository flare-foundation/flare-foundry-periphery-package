// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import { IWalletKeyManager } from "./IWalletKeyManager.sol";

/**
 * Periphery-defined composition of published diamond facets.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IFlareTeeManagerWalletKeys is
    IWalletKeyManager
{
}
