// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IVaultsFacet} from "./IVaultsFacet.sol";

/**
 * @title IReaderFacet
 * @notice Interface for the ReaderFacet contract.
 */
interface IReaderFacet {

    /**
     * @notice Token address and balance pair.
     */
    struct TokenBalance {
        /// @notice Token address.
        address token;
        /// @notice Token balance.
        uint256 balance;
    }

    /**
     * @notice Vault balance with share and asset amounts.
     */
    struct VaultBalance {
        /// @notice Vault ID.
        uint256 vaultId;
        /// @notice Vault address.
        address vaultAddress;
        /// @notice Vault type.
        IVaultsFacet.VaultType vaultType;
        /// @notice Number of shares held.
        uint256 shares;
        /// @notice Equivalent asset value of the shares.
        uint256 assets;
    }

    /**
     * @notice Aggregated account balances.
     */
    struct AccountBalances {
        /// @notice Native token balance.
        uint256 natBalance;
        /// @notice Wrapped native token balance.
        TokenBalance wNat;
        /// @notice FAsset (fXRP) balance.
        TokenBalance fXrp;
        /// @notice Vault balances.
        VaultBalance[] vaults;
    }

    /**
     * @notice Agent vault information.
     */
    struct AgentVaultDetails {
        /// @notice Agent vault ID.
        uint256 agentVaultId;
        /// @notice Agent vault address.
        address agentVaultAddress;
    }

    /**
     * @notice Vault information.
     */
    struct VaultDetails {
        /// @notice Vault ID.
        uint256 vaultId;
        /// @notice Vault address.
        address vaultAddress;
        /// @notice Vault type.
        IVaultsFacet.VaultType vaultType;
    }

    /**
     * @notice Reverts if the vault type is not supported.
     * @param vaultType The unsupported vault type.
     */
    error UnsupportedVaultType(IVaultsFacet.VaultType vaultType);

    /**
     * @notice Get all balances for an account.
     * @param _account The address.
     * @return _balances The account balances (NAT, WNAT, FXRP, vault balances).
     */
    function getBalances(
        address _account
    )
        external view
        returns (AccountBalances memory _balances);

    /**
     * @notice Get all balances for a personal account by XRPL address.
     * @param _xrplOwner The XRPL owner address.
     * @return _balances The account balances (NAT, WNAT, FXRP, vault balances).
     */
    function getBalances(
        string calldata _xrplOwner
    )
        external view
        returns (AccountBalances memory _balances);

    /**
     * @notice Get all registered agent vaults.
     * @return _agentVaults The list of agent vaults.
     */
    function agentVaults()
        external view
        returns (AgentVaultDetails[] memory _agentVaults);

    /**
     * @notice Get all registered vaults.
     * @return _vaults The list of vaults.
     */
    function vaults()
        external view
        returns (VaultDetails[] memory _vaults);

    /**
     * @notice Check if a Flare address is a smart account (personal account).
     * @param _address The Flare address to check.
     * @return _isSmartAccount True if the address is a personal account.
     * @return _xrplOwner The XRPL owner address if it is a personal account.
     */
    function isSmartAccount(
        address _address
    )
        external view
        returns (bool _isSmartAccount, string memory _xrplOwner);
}
