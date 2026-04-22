// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IAgentVaultsFacet
 * @notice Interface for the AgentVaultsFacet contract.
 */
interface IAgentVaultsFacet {

    /**
     * @notice Emitted when an agent vault is added.
     * @param agentVaultId The agent vault ID.
     * @param agentVaultAddress The agent vault address.
     */
    event AgentVaultAdded(
        uint256 indexed agentVaultId,
        address indexed agentVaultAddress
    );

    /**
     * @notice Emitted when an agent vault is removed.
     * @param agentVaultId The agent vault ID.
     * @param agentVaultAddress The agent vault address.
     */
    event AgentVaultRemoved(
        uint256 indexed agentVaultId,
        address indexed agentVaultAddress
    );

    /**
     * @notice Reverts if array lengths do not match.
     */
    error AgentsVaultsLengthsMismatch();

    /**
     * @notice Reverts if the agent vault ID is zero.
     * @param index The index in the input array.
     */
    error AgentVaultIdZero(
        uint256 index
    );

    /**
     * @notice Reverts if the agent vault ID is already added.
     * @param agentVaultId The agent vault ID.
     */
    error AgentVaultIdAlreadyAdded(
        uint256 agentVaultId
    );

    /**
    * @notice Reverts if the agent vault address is zero.
    * @param index The index in the input array.
    */
    error AgentVaultAddressZero(
        uint256 index
    );

    /**
     * @notice Reverts if the agent vault address is already added.
     * @param agentVaultAddress The agent vault address.
     */
    error AgentVaultAddressAlreadyAdded(
        address agentVaultAddress
    );

    /**
     * @notice Reverts if the agent vault is invalid.
     * @param agentVaultId The agent vault ID.
     */
    error InvalidAgentVault(
        uint256 agentVaultId
    );

    /**
     * @notice Reverts if the agent is not available.
     * @param agentVault The agent vault address.
     */
    error AgentNotAvailable(
        address agentVault
    );

    /**
     * Returns the list of registered agent vault IDs and their corresponding addresses.
     * @return _agentVaultIds The list of registered agent vault IDs.
     * @return _agentVaultAddresses The list of registered agent vault addresses.
     */
    function getAgentVaults()
        external view
        returns (uint256[] memory _agentVaultIds, address[] memory _agentVaultAddresses);
}