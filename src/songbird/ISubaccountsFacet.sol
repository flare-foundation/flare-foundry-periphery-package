// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/// @dev Reserved subaccount type: "not configured". Never has an implementation. Every other
/// value is an allocation this deployment made, not a protocol concept: the ids in use are in
/// `deployment/lib/SubaccountTypes.sol` and published in `docs/specs/ApiReference.md`.
uint256 constant SUBACCOUNT_TYPE_NONE = 0;

/**
 * @title ISubaccountsFacet
 * @notice Interface for the SubaccountsFacet contract: the type registry and creation route
 * shared by every subaccount type. The controller (Diamond) is the beacon for subaccounts; a
 * proxy resolves its implementation through {implementationForType} using its fixed type.
 * @dev The subaccount type is a raw `uint256` rather than an enum on purpose: the proxy creation
 * code - and with it the type's encoding in the constructor arguments and the initializer call -
 * is frozen for deterministic CREATE2 addresses, and a compiled enum
 * decoder rejects values outside the range it was compiled with, which would make future type
 * values undeployable through the frozen artifact. Type `0` is reserved and invalid; any other
 * value is usable once governance registers an implementation for it.
 */
interface ISubaccountsFacet {

    /**
     * @notice Emitted when the subaccount implementation is set for a type.
     * @param subaccountType The subaccount type.
     * @param implementation The implementation address set for the type.
     */
    event SubaccountImplementationSet(
        uint256 indexed subaccountType,
        address implementation
    );

    /**
     * @notice Emitted when a new subaccount is created.
     * @param subaccount The deployed subaccount contract address.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param subaccountType The subaccount type.
     */
    event SubaccountCreated(
        address indexed subaccount,
        address indexed parentPersonalAccount,
        uint256 indexed subaccountType
    );

    /**
     * @notice Reverts if the subaccount implementation address is invalid.
     */
    error InvalidSubaccountImplementation();

    /**
     * @notice Reverts if the subaccount type is invalid (the reserved type `0`).
     */
    error InvalidSubaccountType();

    /**
     * @notice Reverts if no implementation is configured for the subaccount type.
     * @param subaccountType The subaccount type without an implementation.
     */
    error SubaccountImplementationNotSet(
        uint256 subaccountType
    );

    /**
     * @notice Reverts if the subaccount was not successfully deployed.
     * @param subaccountAddress The address of the subaccount.
     */
    error SubaccountNotSuccessfullyDeployed(
        address subaccountAddress
    );

    /**
     * @notice Creates the subaccount for an XRPL owner if it does not exist yet.
     * @dev Permissionless, idempotent and not pause-gated, as `createPersonalAccount` is. An
     * executor uses it to materialize a subaccount whose predicted address already received
     * assets, so that they can be swept; a user operation uses it as its first call, before
     * calling a method on the subaccount. The parent Personal Account is created along with it
     * when it does not exist yet, on every chain: a codeless parent leaves the account with no
     * caller and no way home on Flare, and on a remote chain leaves what the compose rails push
     * to it spendable by no one. Nothing can create it from the subaccount afterwards, which
     * holds its address while the deployment is keyed by the owner string. Requires a
     * registered implementation for the type and for the Personal Account.
     * @param _xrplOwner The XRPL address of the owner.
     * @param _subaccountType The subaccount type.
     * @return The subaccount contract address.
     */
    function createSubaccount(
        string calldata _xrplOwner,
        uint256 _subaccountType
    )
        external
        returns (address);

    /**
     * @notice Get the subaccount for a given XRPL owner and subaccount type.
     * @param _xrplOwner The XRPL address of the owner.
     * @param _subaccountType The subaccount type.
     * @return The subaccount address associated with the XRPL owner
     * or the computed address if not yet deployed.
     */
    function getSubaccount(
        string calldata _xrplOwner,
        uint256 _subaccountType
    )
        external view
        returns (address);

    /**
     * @notice Returns the implementation address for a given subaccount type.
     * @dev The frozen subaccount proxy creation code embeds this exact selector: renaming it
     * shifts every predicted subaccount address (a refreeze, only possible before the first
     * deployment).
     * @param _subaccountType The subaccount type to resolve.
     * @return The implementation address, or the zero address if not configured.
     */
    function implementationForType(
        uint256 _subaccountType
    )
        external view
        returns (address);
}
