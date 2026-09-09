// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import { IMachineManager } from "./IMachineManager.sol";
import { IMachineEmergencyPause } from "./IMachineEmergencyPause.sol";
import { IVerification } from "./IVerification.sol";

/**
 * Periphery-defined composition of published diamond facets.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IFlareTeeManagerMachines is
    IMachineManager,
    IMachineEmergencyPause,
    IVerification
{
}
