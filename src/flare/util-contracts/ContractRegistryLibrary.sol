// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlareContractRegistry} from "./userInterfaces/IFlareContractRegistry.sol";
// Auto generated imports
// AUTO GENERATED - DO NOT EDIT BELOW THIS LINE
import { IStateConnector } from "../stateConnector/interface/IStateConnector.sol";
import { IPriceSubmitter } from "../ftso/userInterfaces/IPriceSubmitter.sol";
import { IFtsoRewardManager } from "../ftso/userInterfaces/IFtsoRewardManager.sol";
import { IFtsoRegistry } from "../ftso/userInterfaces/IFtsoRegistry.sol";
import { IVoterWhitelister } from "../ftso/userInterfaces/IVoterWhitelister.sol";
import { IDistributionToDelegators } from "../distribution/userInterfaces/IDistributionToDelegators.sol";
import { IFtsoManager } from "../ftso/userInterfaces/IFtsoManager.sol";
import { IWNat } from "../util-contracts/token/userInterfaces/IWNat.sol";
import { IGenericRewardManager } from "../util-contracts/tokenPools/userInterfaces/IGenericRewardManager.sol"; 
// END AUTO GENERATED - DO NOT EDIT ABOVE THIS LINE

// Library is intended to be used inline, so the strings are all memory allocated (instead of calldata)
library FlareContractsRegistryLibrary {
    address internal constant FLARE_CONTRACT_REGISTRY_ADDRESS =
        0xaD67FE66660Fb8dFE9d6b1b4240d8650e30F6019;

    IFlareContractRegistry internal constant FLARE_CONTRACT_REGISTRY =
        IFlareContractRegistry(FLARE_CONTRACT_REGISTRY_ADDRESS);

    /**
     * @notice Returns contract address for the given name - might be address(0)
     * @param _name             name of the contract
     */
    function getContractAddressByName(
        string memory _name
    ) internal view returns (address) {
        return FLARE_CONTRACT_REGISTRY.getContractAddressByName(_name);
    }

    /**
     * @notice Returns contract address for the given name hash - might be address(0)
     * @param _nameHash         hash of the contract name (keccak256(abi.encode(name))
     */
    function getContractAddressByHash(
        bytes32 _nameHash
    ) internal view returns (address) {
        return FLARE_CONTRACT_REGISTRY.getContractAddressByHash(_nameHash);
    }

    /**
     * @notice Returns contract addresses for the given names - might be address(0)
     * @param _names            names of the contracts
     */
    function getContractAddressesByName(
        string[] memory _names
    ) internal view returns (address[] memory) {
        return FLARE_CONTRACT_REGISTRY.getContractAddressesByName(_names);
    }

    /**
     * @notice Returns contract addresses for the given name hashes - might be address(0)
     * @param _nameHashes       hashes of the contract names (keccak256(abi.encode(name))
     */
    function getContractAddressesByHash(
        bytes32[] memory _nameHashes
    ) internal view returns (address[] memory) {
        return FLARE_CONTRACT_REGISTRY.getContractAddressesByHash(_nameHashes);
    }

    /**
     * @notice Returns all contract names and corresponding addresses
     */
    function getAllContracts()
        internal
        view
        returns (string[] memory _names, address[] memory _addresses)
    {
        return FLARE_CONTRACT_REGISTRY.getAllContracts();
    }

    // Nice typed getters for all the important contracts
    // AUTO GENERATED - DO NOT EDIT BELOW THIS LINE
    function getStateConnector() internal view returns(IStateConnector){
return IStateConnector(FLARE_CONTRACT_REGISTRY.getContractAddressByName("StateConnector"));

}


function getPriceSubmitter() internal view returns(IPriceSubmitter){
return IPriceSubmitter(FLARE_CONTRACT_REGISTRY.getContractAddressByName("PriceSubmitter"));

}


function getFtsoRewardManager() internal view returns(IFtsoRewardManager){
return IFtsoRewardManager(FLARE_CONTRACT_REGISTRY.getContractAddressByName("FtsoRewardManager"));

}


function getFtsoRegistry() internal view returns(IFtsoRegistry){
return IFtsoRegistry(FLARE_CONTRACT_REGISTRY.getContractAddressByName("FtsoRegistry"));

}


function getVoterWhitelister() internal view returns(IVoterWhitelister){
return IVoterWhitelister(FLARE_CONTRACT_REGISTRY.getContractAddressByName("VoterWhitelister"));

}


function getDistributionToDelegators() internal view returns(IDistributionToDelegators){
return IDistributionToDelegators(FLARE_CONTRACT_REGISTRY.getContractAddressByName("DistributionToDelegators"));

}


function getFtsoManager() internal view returns(IFtsoManager){
return IFtsoManager(FLARE_CONTRACT_REGISTRY.getContractAddressByName("FtsoManager"));

}


function getWNat() internal view returns(IWNat){
return IWNat(FLARE_CONTRACT_REGISTRY.getContractAddressByName("WNat"));

}


function getValidatorRewardManager() internal view returns(IGenericRewardManager){
return IGenericRewardManager(FLARE_CONTRACT_REGISTRY.getContractAddressByName("ValidatorRewardManager"));

}
 
    // END AUTO GENERATED - DO NOT EDIT ABOVE THIS LINE
}
