// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IDiamondCut} from "./diamond/interfaces/IDiamondCut.sol";
import {IDiamondLoupe} from "./diamond/interfaces/IDiamondLoupe.sol";
import {IERC165} from "./diamond/interfaces/IERC165.sol";
import {IERC173} from "./diamond/interfaces/IERC173.sol";

import {IAgentVaultsFacet} from "./IAgentVaultsFacet.sol";
import {IExecutorsFacet} from "./IExecutorsFacet.sol";
import {IInstructionFeesFacet} from "./IInstructionFeesFacet.sol";
import {IInstructionsFacet} from "./IInstructionsFacet.sol";
import {IPaymentProofsFacet} from "./IPaymentProofsFacet.sol";
import {IPersonalAccountsFacet} from "./IPersonalAccountsFacet.sol";
import {ISwapFacet} from "./ISwapFacet.sol";
import {ITimelockFacet} from "./ITimelockFacet.sol";
import {IVaultsFacet} from "./IVaultsFacet.sol";
import {IXrplProviderWalletsFacet} from "./IXrplProviderWalletsFacet.sol";

/**
 * @title IMasterAccountController
 * @notice Interface for the MasterAccountController contract,
 * which manages personal accounts and executes XRPL instructions.
 */
interface IMasterAccountController is
    IDiamondCut,
    IDiamondLoupe,
    IERC165,
    IERC173,
    IAgentVaultsFacet,
    IExecutorsFacet,
    IInstructionFeesFacet,
    IInstructionsFacet,
    IPaymentProofsFacet,
    IPersonalAccountsFacet,
    ISwapFacet,
    ITimelockFacet,
    IVaultsFacet,
    IXrplProviderWalletsFacet
{}
