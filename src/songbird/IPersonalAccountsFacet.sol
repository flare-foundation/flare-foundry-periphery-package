// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

/**
 * @title IPersonalAccountsFacet
 * @notice Interface for the PersonalAccountsFacet contract.
 */
interface IPersonalAccountsFacet is IBeacon {

    /**
     * @notice Emitted when the PersonalAccount implementation address is set.
     * @param newImplementation The new implementation address.
     */
    event PersonalAccountImplementationSet(
        address newImplementation
    );

    /**
     * @notice Emitted when a new PersonalAccount is created.
     * @param personalAccount The deployed PersonalAccount contract address.
     * @param xrplOwner The XRPL owner address.
     */
    event PersonalAccountCreated(
        address indexed personalAccount,
        string xrplOwner
    );

    /**
     * @notice Reverts if the personal account implementation address is invalid.
     */
    error InvalidPersonalAccountImplementation();

    /**
     * @notice Reverts if the personal account was not successfully deployed.
     * @param personalAccountAddress The address of the personal account.
     */
    error PersonalAccountNotSuccessfullyDeployed(
        address personalAccountAddress
    );

    /**
     * @notice Creates the Personal Account of an XRPL owner on this chain, at its deterministic
     * address (the same on every chain), and registers it so {getPersonalAccount} answers with
     * it.
     * @dev Permissionless, idempotent and not pause-gated. The frozen derivation commits to the
     * owner and this controller, so the caller gains no authority - on Flare the account obeys
     * only its owner's XRPL signatures, on a remote chain only the authenticated compose of its
     * Flare twin. It lets anyone materialize an account before the owner acts (an executor
     * completing a loan subaccount's `sweepRedeem` needs the parent to exist), where Flare
     * otherwise creates accounts lazily on the owner's first instruction; on a remote chain
     * the routes are this one and `createSubaccount`, which creates the parent along with the
     * subaccount. It is not pause-gated: the creation code is public and the singleton factory
     * permissionless, so a gate would withhold the record, not the account. A registered
     * Personal Account implementation is required (the frozen proxy resolves it through the
     * controller-as-beacon at construction); an empty owner reverts in `initialize`.
     * @param _xrplOwner The XRPL owner.
     * @return The Personal Account address.
     */
    function createPersonalAccount(
        string calldata _xrplOwner
    )
        external
        returns (address);

    /**
     * @notice Get the PersonalAccount contract for a given XRPL owner.
     * @param _xrplOwner The XRPL address of the owner.
     * @return The PersonalAccount contract address associated with the XRPL owner
     * or the computed address if not yet deployed.
     */
    function getPersonalAccount(
        string calldata _xrplOwner
    )
        external view
        returns (address);
}