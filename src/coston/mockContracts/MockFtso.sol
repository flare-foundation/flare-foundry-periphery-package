// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9.0;

// Warning: due to different implementations of
// wrapping this mock contract might not work as expected under 0.7 vs 0.8 version of solidity

import "../ftso/ftso/interface/IIFtso.sol";

contract MockFtso is IIFtso {
    bool public immutable override active = true;
    string public override symbol;

    uint256 private price;
    uint256 private priceTimestamp;
    uint256 private decimals;

    uint256 private priceFromTrustedProviders;
    uint256 private priceTimestampFromTrustedProviders;

    constructor(string memory _symbol, uint256 _decimals) {
        symbol = _symbol;
        decimals = _decimals;
    }

    function setDecimals(uint256 _decimals) external {
        decimals = _decimals;
    }

    function setCurrentPrice(uint256 _price, uint256 _ageSeconds) external {
        price = _price;
        priceTimestamp = block.timestamp - _ageSeconds;
    }

    function setCurrentPriceFromTrustedProviders(
        uint256 _price,
        uint256 _ageSeconds
    ) external {
        priceFromTrustedProviders = _price;
        priceTimestampFromTrustedProviders = block.timestamp - _ageSeconds;
    }

    // in FAsset system, we only need current price

    function getCurrentPrice()
        external
        view
        override
        returns (uint256 _price, uint256 _timestamp)
    {
        return (price, priceTimestamp);
    }

    function getCurrentPriceWithDecimals()
        external
        view
        override
        returns (
            uint256 _price,
            uint256 _timestamp,
            uint256 _assetPriceUsdDecimals
        )
    {
        return (price, priceTimestamp, decimals);
    }

    function getCurrentPriceFromTrustedProviders()
        external
        view
        override
        returns (uint256 _price, uint256 _timestamp)
    {
        return (priceFromTrustedProviders, priceTimestampFromTrustedProviders);
    }

    function getCurrentPriceWithDecimalsFromTrustedProviders()
        external
        view
        override
        returns (
            uint256 _price,
            uint256 _timestamp,
            uint256 _assetPriceUsdDecimals
        )
    {
        return (
            priceFromTrustedProviders,
            priceTimestampFromTrustedProviders,
            decimals
        );
    }

    // unused

    function getCurrentEpochId() external view override returns (uint256) {}

    function getEpochId(
        uint256 _timestamp
    ) external view override returns (uint256) {}

    function getRandom(
        uint256 _epochId
    ) external view override returns (uint256) {}

    function getEpochPrice(
        uint256 _epochId
    ) external view override returns (uint256) {}

    function getPriceEpochData()
        external
        view
        override
        returns (
            uint256 _epochId,
            uint256 _epochSubmitEndTime,
            uint256 _epochRevealEndTime,
            uint256 _votePowerBlock,
            bool _fallbackMode
        )
    {}

    function getPriceEpochConfiguration()
        external
        view
        override
        returns (
            uint256 _firstEpochStartTs,
            uint256 _submitPeriodSeconds,
            uint256 _revealPeriodSeconds
        )
    {}

    function getEpochPriceForVoter(
        uint256 _epochId,
        address _voter
    ) external view override returns (uint256) {}

    function getCurrentPriceDetails()
        external
        view
        override
        returns (
            uint256 _price,
            uint256 _priceTimestamp,
            PriceFinalizationType _priceFinalizationType,
            uint256 _lastPriceEpochFinalizationTimestamp,
            PriceFinalizationType _lastPriceEpochFinalizationType
        )
    {}

    function getCurrentRandom() external view override returns (uint256) {}

    // IFtsoGenesis

    function revealPriceSubmitter(
        address _voter,
        uint256 _epochId,
        uint256 _price,
        uint256 _random,
        uint256 _wNatVP
    ) external override {}

    function submitPriceHashSubmitter(
        address _sender,
        uint256 _epochId,
        bytes32 _hash
    ) external override {}

    function wNatVotePowerCached(
        address _voter,
        uint256 _epochId
    ) external override returns (uint256) {}

    // IIFtso

    function finalizePriceEpoch(
        uint256 _epochId,
        bool _returnRewardData
    )
        external
        override
        returns (
            address[] memory _eligibleAddresses,
            uint256[] memory _natWeights,
            uint256 _totalNatWeight
        )
    {}

    function fallbackFinalizePriceEpoch(uint256 _epochId) external override {}

    function forceFinalizePriceEpoch(uint256 _epochId) external override {}

    function activateFtso(
        uint256 _firstEpochStartTs,
        uint256 _submitPeriodSeconds,
        uint256 _revealPeriodSeconds
    ) external override {}

    function deactivateFtso() external override {}

    function updateInitialPrice(
        uint256 _initialPriceUSD,
        uint256 _initialPriceTimestamp
    ) external override {}

    function configureEpochs(
        uint256 _maxVotePowerNatThresholdFraction,
        uint256 _maxVotePowerAssetThresholdFraction,
        uint256 _lowAssetUSDThreshold,
        uint256 _highAssetUSDThreshold,
        uint256 _highAssetTurnoutThresholdBIPS,
        uint256 _lowNatTurnoutThresholdBIPS,
        uint256 _elasticBandRewardBIPS,
        uint256 _elasticBandWidthPPM,
        address[] memory _trustedAddresses
    ) external override {}

    function setAsset(IIVPToken _asset) external override {}

    function setAssetFtsos(IIFtso[] memory _assetFtsos) external override {}

    function setVotePowerBlock(uint256 _blockNumber) external override {}

    function initializeCurrentEpochStateForReveal(
        uint256 _circulatingSupplyNat,
        bool _fallbackMode
    ) external override {}

    function ftsoManager() external view override returns (address) {}

    function getAsset() external view override returns (IIVPToken) {}

    function getAssetFtsos() external view override returns (IIFtso[] memory) {}

    function epochsConfiguration()
        external
        view
        override
        returns (
            uint256 _maxVotePowerNatThresholdFraction,
            uint256 _maxVotePowerAssetThresholdFraction,
            uint256 _lowAssetUSDThreshold,
            uint256 _highAssetUSDThreshold,
            uint256 _highAssetTurnoutThresholdBIPS,
            uint256 _lowNatTurnoutThresholdBIPS,
            uint256 _elasticBandRewardBIPS,
            uint256 _elasticBandWidthPPM,
            address[] memory _trustedAddresses
        )
    {}

    function getVoteWeightingParameters()
        external
        view
        override
        returns (
            IIVPToken[] memory _assets,
            uint256[] memory _assetMultipliers,
            uint256 _totalVotePowerNat,
            uint256 _totalVotePowerAsset,
            uint256 _assetWeightRatio,
            uint256 _votePowerBlock
        )
    {}

    function wNat() external view override returns (IIVPToken) {}

    function ASSET_PRICE_USD_DECIMALS()
        external
        view
        override
        returns (uint256)
    {}
}
