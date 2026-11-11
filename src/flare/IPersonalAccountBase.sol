// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IControlledAccount} from "./IControlledAccount.sol";

/**
 * @title IPersonalAccountBase
 * @notice The identity every Personal Account implementation exposes, on Flare and on the remote
 * chains. The frozen `PersonalAccountProxy` creation code delegate-calls `initialize` from the
 * proxy constructor, so every implementation behind the PA beacon must implement exactly this.
 * Only the initializer's ABI is frozen with the proxy creation code; the rest of this interface
 * is the protocol's compatibility requirement on every implementation.
 */
interface IPersonalAccountBase is IControlledAccount {

    /**
     * @notice Emitted when a Personal Account is initialized.
     * @param controllerAddress The controller address.
     * @param xrplOwner The XRPL owner.
     */
    event PersonalAccountInitialized(
        address indexed controllerAddress,
        string xrplOwner
    );

    /**
     * @notice Reverts if the XRPL owner is invalid (empty).
     */
    error InvalidXrplOwner();

    /**
     * @notice Initializes the account. Delegate-called by the Personal Account proxy's
     * constructor; implementations reject re-initialization and lock the implementation
     * contract itself in their constructor.
     * @param _controllerAddress MasterAccountController address.
     * @param _xrplOwner The XRPL owner (non-empty).
     */
    function initialize(
        address _controllerAddress,
        string calldata _xrplOwner
    )
        external;

    /**
     * @notice Returns the XRPL owner this account belongs to.
     * @return The XRPL owner.
     */
    function xrplOwner()
        external view
        returns (string memory);

    /**
     * @notice Returns the implementation this account currently runs, resolved through the
     * controller-as-beacon.
     * @return The implementation address.
     */
    function implementation()
        external view
        returns (address);
}
