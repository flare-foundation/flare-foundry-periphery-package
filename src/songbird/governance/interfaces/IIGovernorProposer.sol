// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;
pragma abicoder v2;

interface IIGovernorProposer {

    /**
     * @notice Determines if account is eligible to submit a proposal
     * @param _account              Address of the queried account
     * @return True if account is eligible for proposal submission, and false otherwise
     */
    function isProposer(address _account) external view returns (bool);

}
