// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IVaultsFacet
 * @notice Interface for the VaultsFacet contract.
 */
interface IVaultsFacet {

    /**
     * @notice Emitted when a vault is added.
     * @param vaultId The vault ID.
     * @param vaultAddress The vault address.
     * @param vaultType The vault type (e.g., 1 = Firelight, 2 = Upshift).
     */
    event VaultAdded(
        uint256 indexed vaultId,
        address indexed vaultAddress,
        uint8 indexed vaultType
    );

    /**
     * @notice Reverts if array lengths do not match.
     */
    error VaultsLengthsMismatch();

    /**
     * @notice Reverts if the vault ID is zero.
     * @param index The index in the input array.
     */
    error VaultIdZero(
        uint256 index
    );

    /**
     * @notice Reverts if the vault ID is already added.
     * @param vaultId The vault ID.
     */
    error VaultIdAlreadyAdded(
        uint256 vaultId
    );

    /**
     * @notice Reverts if the vault address is zero.
     * @param index The index in the input array.
     */
    error VaultAddressZero(
        uint256 index
    );

    /**
     * @notice Reverts if the vault address is already added.
     * @param vaultAddress The vault address.
     */
    error VaultAddressAlreadyAdded(
        address vaultAddress
    );

    /**
     * @notice Reverts if the vault ID is invalid.
     * @param vaultId The vault ID.
     */
    error InvalidVaultId(
        uint256 vaultId
    );

    /**
     * @notice Reverts if the vault type is invalid.
     * @param vaultType The vault type.
     */
    error InvalidVaultType(
        uint8 vaultType
    );

    /**
     * Returns the list of registered vault IDs, their corresponding addresses and types.
     * @return _vaultIds The list of registered vault IDs.
     * @return _vaultAddresses The list of vault addresses corresponding to the vault IDs.
     * @return _vaultTypes The list of vault types corresponding to the vault IDs.
     */
    function getVaults()
        external view
        returns (uint256[] memory _vaultIds, address[] memory _vaultAddresses, uint8[] memory _vaultTypes);
}