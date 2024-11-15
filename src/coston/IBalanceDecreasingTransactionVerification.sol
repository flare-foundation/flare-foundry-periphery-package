// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./BalanceDecreasingTransaction.sol";

interface IBalanceDecreasingTransactionVerification {

   function verifyBalanceDecreasingTransaction(
      BalanceDecreasingTransaction.Proof calldata _proof
   ) external view returns (bool _proved);
}
   