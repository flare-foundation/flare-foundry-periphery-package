// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9.0;

import "../ftso/genesis/interface/IFtsoGenesis.sol";
import "../ftso/genesis/interface/IFtsoRegistryGenesis.sol";
import "../ftso/genesis/interface/IFtsoManagerGenesis.sol";
import {IPriceSubmitter} from "../ftso/userInterfaces/IPriceSubmitter.sol";

contract GatewayPriceSubmitter is IPriceSubmitter {
    IFtsoRegistryGenesis public ftsoRegistryField;
    address public voterWhitelisterField;
    IFtsoManagerGenesis public ftsoManagerField;

    function submitHash(uint256 _epochId, bytes32 _hashe) external override {
        revert("Not implemented");
    }

    function revealPrices(
        uint256 _epochId,
        uint256[] memory _ftsoIndices,
        uint256[] memory _prices,
        uint256 _randoms
    ) external override {
        revert("Not implemented");
    }

    function setFtsoRegistry(IFtsoRegistryGenesis _ftsoRegistry) external {
        ftsoRegistryField = _ftsoRegistry;
    }

    function setVoterWhitelister(address _voterWhitelister) external {
        voterWhitelisterField = _voterWhitelister;
    }

    function setFtsoManager(IFtsoManagerGenesis _ftsoManager) external {
        ftsoManagerField = _ftsoManager;
    }

    function voterWhitelistBitmap(address _voter)
        external
        view
        override
        returns (uint256)
    {
        revert("Not implemented");
    }

    function getVoterWhitelister() external view override returns (address) {
        return voterWhitelisterField;
    }

    function getFtsoRegistry()
        external
        view
        override
        returns (IFtsoRegistryGenesis)
    {
        return ftsoRegistryField;
    }

    function getFtsoManager()
        external
        view
        override
        returns (IFtsoManagerGenesis)
    {
        return ftsoManagerField;
    }

    function getCurrentRandom() external view override returns (uint256) {
        revert("Not implemented");
    }

    function getRandom(uint256 _epochId)
        external
        view
        override
        returns (uint256)
    {
        revert("Not implemented");
    }
}
