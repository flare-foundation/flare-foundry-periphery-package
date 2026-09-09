// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import { IInstructions } from "./IInstructions.sol";
import { IVrf } from "./IVrf.sol";
import { IOperationFees } from "./IOperationFees.sol";

/**
 * Periphery-defined composition of published diamond facets.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IFlareTeeManagerOperations is
    IInstructions,
    IVrf,
    IOperationFees
{
}
