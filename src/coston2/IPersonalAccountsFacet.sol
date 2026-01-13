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