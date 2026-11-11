// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IControlledAccount} from "./IControlledAccount.sol";

/**
 * @title ISubaccount
 * @notice The type-generic subaccount surface every implementation must expose. The frozen
 * `SubaccountProxy` creation code embeds `initialize`'s exact selector and delegate-calls
 * it from the proxy constructor, so a new subaccount type is not merely "any contract with a
 * registered implementation": its implementation must implement this interface. Only the
 * initializer's ABI is frozen with the proxy creation code — changing it shifts every predicted
 * subaccount address; the rest of this interface is the protocol's requirement on every
 * implementation, not something the proxy embeds.
 */
interface ISubaccount is IControlledAccount {

    /**
     * @notice Emitted when a subaccount is initialized.
     * @param controllerAddress The controller address.
     * @param parentPersonalAccount The parent Personal Account address (the same address on
     * every chain; codeless on a remote chain until its remote Personal Account is created).
     * @param subaccountType The subaccount type.
     */
    event SubaccountInitialized(
        address indexed controllerAddress,
        address indexed parentPersonalAccount,
        uint256 indexed subaccountType
    );

    /**
     * @notice Reverts if the parent Personal Account address is invalid (zero).
     */
    error InvalidParentPersonalAccount();

    /**
     * @notice Reverts if a parent-driven method is called by anything other than the parent
     * Personal Account (on a remote chain, the remote Personal Account executing the user's
     * signed cross-chain user operation).
     */
    error OnlyParent();

    /**
     * @notice Initializes the subaccount. Delegate-called by the subaccount proxy's
     * constructor; implementations must reject re-initialization and lock the implementation
     * contract itself in their own constructor.
     * @param _controllerAddress MasterAccountController address.
     * @param _parentPersonalAccount Parent Personal Account address.
     * @param _subaccountType The subaccount type.
     */
    function initialize(
        address _controllerAddress,
        address _parentPersonalAccount,
        uint256 _subaccountType
    )
        external;

    /**
     * @notice Returns the parent Personal Account address for this subaccount.
     * @return The parent Personal Account address.
     */
    function parentPersonalAccount()
        external view
        returns (address);

    /**
     * @notice Returns the subaccount type.
     * @return The subaccount type.
     */
    function subaccountType()
        external view
        returns (uint256);

    /**
     * @notice Returns the implementation address of the subaccount.
     * @return The implementation address.
     */
    function implementation()
        external view
        returns (address);
}
