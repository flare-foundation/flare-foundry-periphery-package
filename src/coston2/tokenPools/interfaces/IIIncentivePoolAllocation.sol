// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;
pragma abicoder v2;

import "./IIIncentivePoolPercentageProvider.sol";
import "./IIIncentivePoolSharingPercentageProvider.sol";

interface IIIncentivePoolAllocation is IIIncentivePoolPercentageProvider, IIIncentivePoolSharingPercentageProvider {
    
}
