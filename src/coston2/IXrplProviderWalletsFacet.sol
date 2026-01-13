// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IXrplProviderWalletsFacet
 * @notice Interface for the XrplProviderWalletsFacet contract.
 */
interface IXrplProviderWalletsFacet {

    /**
     * @notice Emitted when an XRPL provider wallet is added.
     * @param xrplProviderWallet The XRPL provider wallet address.
     */
    event XrplProviderWalletAdded(
        string xrplProviderWallet
    );

    /**
     * @notice Emitted when an XRPL provider wallet is removed.
     * @param xrplProviderWallet The XRPL provider wallet address.
     */
    event XrplProviderWalletRemoved(
        string xrplProviderWallet
    );

    /**
     * @notice Reverts if the XRPL provider wallet is invalid.
     * @param xrplProviderWallet The XRPL provider wallet address.
     */
    error InvalidXrplProviderWallet(
        string xrplProviderWallet
    );

    /**
     * @notice Reverts if the XRPL provider wallet already exists.
     * @param xrplProviderWallet The XRPL provider wallet address.
     */
    error XrplProviderWalletAlreadyExists(
        string xrplProviderWallet
    );

    /**
     * Returns the list of registered XRPL provider wallets.
     * @return The list of registered XRPL provider wallets.
     */
    function getXrplProviderWallets()
        external view
        returns (string[] memory);
}