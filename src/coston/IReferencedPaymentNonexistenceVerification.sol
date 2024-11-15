// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./ReferencedPaymentNonexistence.sol";

interface IReferencedPaymentNonexistenceVerification {

   function verifyReferencedPaymentNonexistence(
      ReferencedPaymentNonexistence.Proof calldata _proof
   ) external view returns (bool _proved);
}
   