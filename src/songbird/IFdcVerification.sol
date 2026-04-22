// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import { IRelay } from "./IRelay.sol";
import { IAddressValidityVerification } from "./IAddressValidityVerification.sol";
import { IBalanceDecreasingTransactionVerification } from "./IBalanceDecreasingTransactionVerification.sol";
import { IConfirmedBlockHeightExistsVerification } from "./IConfirmedBlockHeightExistsVerification.sol";
import { IEVMTransactionVerification } from "./IEVMTransactionVerification.sol";
import { IPaymentVerification } from "./IPaymentVerification.sol";
import { IReferencedPaymentNonexistenceVerification } from "./IReferencedPaymentNonexistenceVerification.sol";
import { IWeb2JsonVerification } from "./IWeb2JsonVerification.sol";
import { IXRPPaymentVerification } from "./IXRPPaymentVerification.sol";
import { IXRPPaymentNonexistenceVerification } from "./IXRPPaymentNonexistenceVerification.sol";


/**
 * FdcVerification interface.
 */
interface IFdcVerification is
    IAddressValidityVerification,
    IBalanceDecreasingTransactionVerification,
    IConfirmedBlockHeightExistsVerification,
    IEVMTransactionVerification,
    IPaymentVerification,
    IReferencedPaymentNonexistenceVerification,
    IWeb2JsonVerification,
    IXRPPaymentVerification,
    IXRPPaymentNonexistenceVerification
{
    /**
     * The FDC protocol id.
     */
    function fdcProtocolId() external view returns (uint8 _fdcProtocolId);

    /**
     * Relay contract address.
     */
    function relay() external view returns (IRelay);
}
