// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./EVMTransaction.sol";

interface IEVMTransactionVerification {

   function verifyEVMTransaction(
      EVMTransaction.Proof calldata _proof
   ) external view returns (bool _proved);
}
   