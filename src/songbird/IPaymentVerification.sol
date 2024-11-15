// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./Payment.sol";

interface IPaymentVerification {

   function verifyPayment(
      Payment.Proof calldata _proof
   ) external view returns (bool _proved);
}
   