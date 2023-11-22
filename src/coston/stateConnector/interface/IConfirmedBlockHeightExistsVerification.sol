// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./ConfirmedBlockHeightExists.sol";

interface IConfirmedBlockHeightExistsVerification {

   function verifyConfirmedBlockHeightExists(
      ConfirmedBlockHeightExists.Proof calldata _proof
   ) external view returns (bool _proved);
}
   