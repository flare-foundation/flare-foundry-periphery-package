// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./AddressValidity.sol";

interface IAddressValidityVerification {

   function verifyAddressValidity(
      AddressValidity.Proof calldata _proof
   ) external view returns (bool _proved);
}
   