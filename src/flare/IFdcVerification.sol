// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./IAddressValidityVerification.sol";
import "./IBalanceDecreasingTransactionVerification.sol";
import "./IConfirmedBlockHeightExistsVerification.sol";
import "./IEVMTransactionVerification.sol";
import "./IPaymentVerification.sol";
import "./IReferencedPaymentNonexistenceVerification.sol";


/**
 * FdcVerification interface.
 */
interface IFdcVerification is
    IAddressValidityVerification,
    IBalanceDecreasingTransactionVerification,
    IConfirmedBlockHeightExistsVerification,
    IEVMTransactionVerification,
    IPaymentVerification,
    IReferencedPaymentNonexistenceVerification
{ }
