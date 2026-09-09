// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import { IWalletManager } from "./IWalletManager.sol";
import { IWalletProjectManager } from "./IWalletProjectManager.sol";
import { IWalletProjectPause } from "./IWalletProjectPause.sol";
import { IWalletBackupManager } from "./IWalletBackupManager.sol";

/**
 * Periphery-defined composition of published diamond facets.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IFlareTeeManagerWallets is
    IWalletManager,
    IWalletProjectManager,
    IWalletProjectPause,
    IWalletBackupManager
{
}
