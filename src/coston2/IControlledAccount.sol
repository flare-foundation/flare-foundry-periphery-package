// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IControlledAccount
 * @notice The one thing every account in the system has - Personal Accounts and subaccounts, on
 * Flare and on the remote chains: a controller (the MasterAccountController diamond), set once
 * at initialization. Every account interface extends this one, so `controllerAddress()` has a
 * single declaration and a single implementation (`ControlledAccountBase`).
 */
interface IControlledAccount {

    /**
     * @notice Reverts if the account is already initialized (including the implementation
     * contract itself, which is locked in its constructor).
     */
    error AlreadyInitialized();

    /**
     * @notice Reverts if the controller address is invalid (zero).
     */
    error InvalidControllerAddress();

    /**
     * @notice Returns the controller (MasterAccountController) address of this account.
     * @return The controller address.
     */
    function controllerAddress()
        external view
        returns (address);
}
