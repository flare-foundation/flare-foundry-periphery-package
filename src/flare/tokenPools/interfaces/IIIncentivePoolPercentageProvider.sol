// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

interface IIIncentivePoolPercentageProvider {
    /**
     * Return the annual incentivePool rate in bips.
     */
    function getAnnualPercentageBips() external returns(uint256);
}
