// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

// solhint-disable func-name-mixedcase
interface IMerkleRootStorage {
    /**
     * Get Merkle root for the round and check for buffer overflows.
     */
    function merkleRoot(uint256 _roundId) external view returns (bytes32);
}
