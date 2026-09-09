// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import {IConfirmedBlockHeightExists} from ".//IConfirmedBlockHeightExists.sol";
import {AssetManagerSettings} from "./data/AssetManagerSettings.sol";
import {CollateralType} from "./data/CollateralType.sol";
import {EmergencyPause} from "./data/EmergencyPause.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * Periphery-defined view of IAssetManager.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IAssetManagerInfo {
    /**
     * Get the asset manager controller, the only address that can change settings.
     * Asset manager must be attached to the asset manager controller in the system contract registry.
     */
    function assetManagerController()
        external view
        returns (address);

    /**
     * Get the f-asset contract managed by this asset manager instance.
     */
    function fAsset()
        external view
        returns (IERC20);

    /**
     * Get the price reader contract used by this asset manager instance.
     */
    function priceReader()
        external view
        returns (address);

    /**
     * Return lot size in UBA (underlying base amount - smallest amount on underlying chain, e.g. satoshi).
     */
    function lotSize()
        external view
        returns (uint256 _lotSizeUBA);

    /**
     * Return asset minting granularity - smallest unit of f-asset stored internally
     * within this asset manager instance.
     */
    function assetMintingGranularityUBA()
        external view
        returns (uint256);

    /**
     * Return asset minting decimals - the number of decimals of precision for minting.

     */
    function assetMintingDecimals()
        external view
        returns (uint256);

    /**
     * Get complete current settings.
     * @return the current settings
     */
    function getSettings()
        external view
        returns (AssetManagerSettings.Data memory);

    /**
     * When `controllerAttached` is true, asset manager has been added to the asset manager controller.
     * This is required for the asset manager to be operational (create agent and minting don't work otherwise).
     */
    function controllerAttached()
        external view
        returns (bool);

    /**
     * If true, the system is in emergency pause mode and most operations (mint, redeem, liquidate) are disabled.
     */
    function emergencyPaused()
        external view
        returns (bool);

    /**
     * Emergency pause level defines which operations are paused:
     * NONE - pause is not active,
     * START_OPERATIONS - prevent starting mint, redeem, liquidation (start/liquidate) and core vault transfer/return,
     * FULL - everything from START_OPERATIONS, plus prevent finishing or defulating already started mints and redeems,
     * FULL_AND_TRANSFER - everything from FULL, plus prevent FAsset transfers.
     */
    function emergencyPauseLevel()
        external view
        returns (EmergencyPause.Level);

    /**
     * The time when emergency pause mode will end automatically.
     */
    function emergencyPausedUntil()
        external view
        returns (uint256);

    /**
     * True if the asset manager is paused.
     * In the paused state, minting is disabled, but all other operations (e.g. redemptions, liquidation) still work.
     * Paused asset manager can be later unpaused.
     */
    function mintingPaused()
        external view
        returns (bool);

    /**
     * Prove that a block with given number and timestamp exists and
     * update the current underlying block info if the provided data is higher.
     * This method should be called by minters before minting and by agent's regularly
     * to prevent current block being too outdated, which gives too short time for
     * minting or redemption payment.
     * NOTE: anybody can call.
     * NOTE: the block/timestamp will only be updated if it is strictly higher than the current value.
     * For mintings and redemptions we also add the duration from the last update (on this chain) to compensate
     * for the time that passed since the last update. This mechanism can be abused by providing old block proof
     * as fresh, which will distort the compensation accounting. Due to monotonicity such an attack will only work
     * if there was no block update for some time. Therefore it is enough to have at least one honest
     * current block updater regularly providing updates to avoid this issue.
     * @param _proof proof that a block with given number and timestamp exists
     */
    function updateCurrentBlock(
        IConfirmedBlockHeightExists.Proof calldata _proof
    ) external;

    /**
     * Get block number and timestamp of the current underlying block known to the f-asset system.
     * @return _blockNumber current underlying block number tracked by asset manager
     * @return _blockTimestamp current underlying block timestamp tracked by asset manager
     * @return _lastUpdateTs the timestamp on this chain when the current underlying block was last updated
     */
    function currentUnderlyingBlock()
        external view
        returns (uint256 _blockNumber, uint256 _blockTimestamp, uint256 _lastUpdateTs);

    /**
     * Get collateral  information about a token.
     */
    function getCollateralType(CollateralType.Class _collateralClass, IERC20 _token)
        external view
        returns (CollateralType.Data memory);

    /**
     * Get the list of all available tokens used for collateral.
     */
    function getCollateralTypes()
        external view
        returns (CollateralType.Data[] memory);

    /**
     * A setting has changed.
     */
    event SettingChanged(
        string name,
        uint256 value);

    /**
     * A setting has changed.
     */
    event SettingArrayChanged(
        string name,
        uint256[] value);

    /**
     * A contract in the settings has changed.
     */
    event ContractChanged(
        string name,
        address value);

    /**
     * Current underlying block number or timestamp has been updated.
     */
    event CurrentUnderlyingBlockUpdated(
        uint256 underlyingBlockNumber,
        uint256 underlyingBlockTimestamp,
        uint256 updatedAt);

    /**
     * New collateral token has been added.
     */
    event CollateralTypeAdded(
        uint8 collateralClass,
        address token,
        uint256 decimals,
        bool directPricePair,
        string assetFtsoSymbol,
        string tokenFtsoSymbol,
        uint256 minCollateralRatioBIPS,
        uint256 safetyMinCollateralRatioBIPS);

    /**
     * System defined collateral ratios for the token have changed (minimal and safety collateral ratio).
     */
    event CollateralRatiosChanged(
        uint8 collateralClass,
        address collateralToken,
        uint256 minCollateralRatioBIPS,
        uint256 safetyMinCollateralRatioBIPS);

    /**
     * Emergency pause was triggered.
     */
    event EmergencyPauseTriggered(
        EmergencyPause.Level externalLevel,
        uint256 externalPausedUntil,
        EmergencyPause.Level governanceLevel,
        uint256 governancePausedUntil);

    /**
     * Emergency pause was canceled.
     */
    event EmergencyPauseCanceled();

    /**
     * Emergency pause total duration was reset by the governance.
     */
    event EmergencyPauseTotalDurationReset();

    /**
     * Minting was paused/unpaused by the governance.
     */
    event MintingPaused(bool paused);
}
