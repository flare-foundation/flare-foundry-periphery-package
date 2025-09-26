// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;
pragma abicoder v2;

import "../../IPChainStakeMirrorVerifier.sol";


/**
 * Internal interface for P-chain stake mirror verifications.
 */
interface IIPChainStakeMirrorVerifier is IPChainStakeMirrorVerifier {

    /**
     * Method for P-chain stake verification using `IPChainStakeMirrorVerifier.PChainStake` data and Merkle proof.
     * @param _stakeData Information about P-chain stake.
     * @param _merkleProof Merkle proof that should be used to prove the P-chain stake.
     * @return True if stake can be verified using provided Merkle proof.
     */
    function verifyStake(
        IPChainStakeMirrorVerifier.PChainStake calldata _stakeData,
        bytes32[] calldata _merkleProof
    )
        external view returns(bool);
}
