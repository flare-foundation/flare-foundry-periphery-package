// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IPauseFacet
 * @notice Interface for the PauseFacet contract.
 */
interface IPauseFacet {

    /**
     * @notice Emitted when the contract is paused.
     * @param account The account that triggered the pause.
     */
    event Paused(address indexed account);

    /**
     * @notice Emitted when the contract is unpaused.
     * @param account The account that triggered the unpause.
     */
    event Unpaused(address indexed account);

    /**
     * @notice Emitted when a pauser is added.
     * @param account The pauser address.
     */
    event PauserAdded(address indexed account);

    /**
     * @notice Emitted when a pauser is removed.
     * @param account The pauser address.
     */
    event PauserRemoved(address indexed account);

    /**
     * @notice Emitted when an unpauser is added.
     * @param account The unpauser address.
     */
    event UnpauserAdded(address indexed account);

    /**
     * @notice Emitted when an unpauser is removed.
     * @param account The unpauser address.
     */
    event UnpauserRemoved(address indexed account);

    /**
     * @notice Reverts if the contract is paused.
     */
    error IsPaused();

    /**
     * @notice Reverts if the caller is not a pauser.
     * @param account The caller address.
     */
    error NotPauser(address account);

    /**
     * @notice Reverts if the caller is not an unpauser.
     * @param account The caller address.
     */
    error NotUnpauser(address account);

    /**
     * @notice Reverts if the address is already a pauser.
     * @param account The address.
     */
    error PauserAlreadyAdded(address account);

    /**
     * @notice Reverts if the address is already an unpauser.
     * @param account The address.
     */
    error UnpauserAlreadyAdded(address account);

    /**
     * @notice Pause the contract. Only callable by pausers.
     */
    function pause() external;

    /**
     * @notice Unpause the contract. Only callable by unpausers.
     */
    function unpause() external;

    /**
     * @notice Returns whether the contract is paused.
     * @return True if paused, false otherwise.
     */
    function isPaused() external view returns (bool);

    /**
     * @notice Returns whether an address is a pauser.
     * @param _account The address to check.
     * @return True if the address is a pauser.
     */
    function isPauser(address _account) external view returns (bool);

    /**
     * @notice Returns whether an address is an unpauser.
     * @param _account The address to check.
     * @return True if the address is an unpauser.
     */
    function isUnpauser(address _account) external view returns (bool);

    /**
     * @notice Returns all pauser addresses.
     * @return The list of pausers.
     */
    function getPausers() external view returns (address[] memory);

    /**
     * @notice Returns all unpauser addresses.
     * @return The list of unpausers.
     */
    function getUnpausers() external view returns (address[] memory);
}
