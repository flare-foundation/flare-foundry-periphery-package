// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "../../IGenericRewardManager.sol";
import "../interfaces/IITokenPool.sol";
import "../../inflation/interfaces/IIInflationReceiverV1.sol";

interface IIGenericRewardManager is IGenericRewardManager, IIInflationReceiverV1, IITokenPool {

    event DailyAuthorizedInflationSet(uint256 authorizedAmountWei);
    event InflationReceived(uint256 amountReceivedWei);

    function activate() external;
    function deactivate() external;

    function distributeRewards(
        address[] memory _addresses,
        uint256[] memory _rewardAmounts
    ) external;

    function getTotals() 
        external view
        returns (
            uint256 _totalAwardedWei,
            uint256 _totalClaimedWei,
            uint256 _totalInflationAuthorizedWei,
            uint256 _totalInflationReceivedWei,
            uint256 _lastInflationAuthorizationReceivedTs,
            uint256 _dailyAuthorizedInflation
        );
}
