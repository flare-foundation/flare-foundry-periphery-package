// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IMorpho
 * @notice Minimal Morpho Blue interface: only the entry points the loan-chain-side
 * subaccount uses. Signatures and the `MarketParams` layout match the canonical
 * `morpho-org/morpho-blue` `IMorpho` v1.0.0. Kept as our own MIT code because the upstream
 * files are GPL-2.0-or-later; conformance is pinned by `test/unit/smartAccounts/MorphoConformance.t.sol`.
 */
interface IMorpho {

    struct MarketParams {
        address loanToken;
        address collateralToken;
        address oracle;
        address irm;
        uint256 lltv;
    }

    /// @dev The market's totals as canonical Morpho stores them - the six words `market(id)`
    /// returns, in that order, and the second argument of the interest rate model's rate
    /// functions.
    struct Market {
        uint128 totalSupplyAssets;
        uint128 totalSupplyShares;
        uint128 totalBorrowAssets;
        uint128 totalBorrowShares;
        uint128 lastUpdate;
        uint128 fee;
    }

    /**
     * @notice Supplies collateral on behalf of an account.
     * @param marketParams The market to supply collateral to.
     * @param assets The amount of collateral to supply.
     * @param onBehalf The account that owns the increased collateral position.
     * @param data Arbitrary callback data (unused by the caller in this repo).
     */
    function supplyCollateral(
        MarketParams memory marketParams,
        uint256 assets,
        address onBehalf,
        bytes memory data
    )
        external;

    /**
     * @notice Borrows assets against the caller's collateral position.
     * @param marketParams The market to borrow from.
     * @param assets The amount of assets to borrow (exactly one of assets/shares is non-zero).
     * @param shares The amount of shares to borrow.
     * @param onBehalf The account that owns the increased borrow position.
     * @param receiver The receiver of the borrowed assets.
     * @return assetsBorrowed The amount of assets borrowed.
     * @return sharesBorrowed The amount of shares borrowed.
     */
    function borrow(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        address receiver
    )
        external
        returns (uint256 assetsBorrowed, uint256 sharesBorrowed);

    /**
     * @notice Accrues interest for a market, updating its totals.
     * @param marketParams The market to accrue interest for.
     */
    function accrueInterest(
        MarketParams memory marketParams
    )
        external;

    /**
     * @notice Withdraws collateral from the caller's position.
     * @param marketParams The market to withdraw collateral from.
     * @param assets The amount of collateral to withdraw.
     * @param onBehalf The account that owns the reduced collateral position.
     * @param receiver The receiver of the withdrawn collateral.
     */
    function withdrawCollateral(
        MarketParams memory marketParams,
        uint256 assets,
        address onBehalf,
        address receiver
    )
        external;

    /**
     * @notice Repays assets on behalf of a borrow position.
     * @param marketParams The market to repay to.
     * @param assets The amount of assets to repay (exactly one of assets/shares is non-zero).
     * @param shares The amount of shares to repay.
     * @param onBehalf The account whose debt is reduced.
     * @param data Arbitrary callback data (unused by the caller in this repo).
     * @return assetsRepaid The amount of assets repaid.
     * @return sharesRepaid The amount of shares repaid.
     */
    function repay(
        MarketParams memory marketParams,
        uint256 assets,
        uint256 shares,
        address onBehalf,
        bytes memory data
    )
        external
        returns (uint256 assetsRepaid, uint256 sharesRepaid);
    /**
     * @notice Returns an account's position in a market.
     * @param id The market id (`keccak256(abi.encode(marketParams))`).
     * @param user The account.
     * @return supplyShares The account's supply shares.
     * @return borrowShares The account's borrow shares.
     * @return collateral The account's collateral.
     */
    function position(
        bytes32 id,
        address user
    )
        external view
        returns (uint256 supplyShares, uint128 borrowShares, uint128 collateral);

    /**
     * @notice Returns a market's state.
     * @param id The market id.
     * @return totalSupplyAssets The market's total supplied assets.
     * @return totalSupplyShares The market's total supply shares.
     * @return totalBorrowAssets The market's total borrowed assets.
     * @return totalBorrowShares The market's total borrow shares.
     * @return lastUpdate The last accrual timestamp; zero means the market was never created.
     * @return fee The market's fee.
     */
    function market(
        bytes32 id
    )
        external view
        returns (
            uint128 totalSupplyAssets,
            uint128 totalSupplyShares,
            uint128 totalBorrowAssets,
            uint128 totalBorrowShares,
            uint128 lastUpdate,
            uint128 fee
        );
}
