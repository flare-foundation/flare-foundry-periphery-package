// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./TypeTemplate.sol";

interface ITypeTemplateVerification {

   function verifyTypeTemplate(
      TypeTemplate.Proof calldata _proof
   ) external view returns (bool _proved);
}
   