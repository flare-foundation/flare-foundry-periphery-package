// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

interface IITokenPool {

    /**
     * @notice Return token pool supply data
     * @return _lockedFundsWei                  Funds that are intentionally locked in the token pool 
     * and not part of circulating supply
     * @return _totalInflationAuthorizedWei     Total inflation authorized amount (wei)
     * @return _totalClaimedWei                 Total claimed amount (wei)
     */
    function getTokenPoolSupplyData() external returns (
        uint256 _lockedFundsWei,
        uint256 _totalInflationAuthorizedWei,
        uint256 _totalClaimedWei
    );
}
