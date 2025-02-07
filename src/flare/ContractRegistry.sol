// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlareContractRegistry} from "./IFlareContractRegistry.sol";

// Auto generated imports
// AUTO GENERATED - DO NOT EDIT BELOW THIS LINE
import {IPriceSubmitter} from "./IPriceSubmitter.sol";
import {IGovernanceSettings} from "./IGovernanceSettings.sol";
import {IFtsoRewardManager} from "./IFtsoRewardManager.sol";
import {IFtsoRegistry} from "./IFtsoRegistry.sol";
import {IVoterWhitelister} from "./IVoterWhitelister.sol";
import {IDistributionToDelegators} from "./IDistributionToDelegators.sol";
import {IFtsoManager} from "./IFtsoManager.sol";
import {IWNat} from "./IWNat.sol";
import {IGovernanceVotePower} from "./IGovernanceVotePower.sol";
import {IClaimSetupManager} from "./IClaimSetupManager.sol";
import {IGenericRewardManager} from "./IGenericRewardManager.sol";
import {IFlareAssetRegistry} from "./IFlareAssetRegistry.sol";
import {IValidatorRegistry} from "./IValidatorRegistry.sol";
import {IFlareContractRegistry} from "./IFlareContractRegistry.sol";
import {IAddressBinder} from "./IAddressBinder.sol";
import {IPChainStakeMirror} from "./IPChainStakeMirror.sol";
import {IPChainStakeMirrorVerifier} from "./IPChainStakeMirrorVerifier.sol";
import {IPChainStakeMirrorMultiSigVoting} from "./IPChainStakeMirrorMultiSigVoting.sol";
import {IRNat} from "./IRNat.sol";
import {IFeeCalculator} from "./IFeeCalculator.sol";
import {FtsoV2Interface} from "./FtsoV2Interface.sol";
import {TestFtsoV2Interface} from "./TestFtsoV2Interface.sol";
import {ProtocolsV2Interface} from "./ProtocolsV2Interface.sol";
import {RandomNumberV2Interface} from "./RandomNumberV2Interface.sol";
import {RewardsV2Interface} from "./RewardsV2Interface.sol";
import {IFdcVerification} from "./IFdcVerification.sol";
import {IFdcHub} from "./IFdcHub.sol";
import {IFdcRequestFeeConfigurations} from "./IFdcRequestFeeConfigurations.sol";
// END AUTO GENERATED - DO NOT EDIT ABOVE THIS LINE

// Library is intended to be used inline, so the strings are all memory allocated (instead of calldata)
library ContractRegistry {
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
    function getPriceSubmitter() internal view returns (IPriceSubmitter) {
        return
            IPriceSubmitter(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("PriceSubmitter"))
                )
            );
    }

    function getGovernanceSettings()
        internal
        view
        returns (IGovernanceSettings)
    {
        return
            IGovernanceSettings(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("GovernanceSettings"))
                )
            );
    }

    function getFtsoRewardManager() internal view returns (IFtsoRewardManager) {
        return
            IFtsoRewardManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoRewardManager"))
                )
            );
    }

    function getFtsoRegistry() internal view returns (IFtsoRegistry) {
        return
            IFtsoRegistry(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoRegistry"))
                )
            );
    }

    function getVoterWhitelister() internal view returns (IVoterWhitelister) {
        return
            IVoterWhitelister(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("VoterWhitelister"))
                )
            );
    }

    function getDistributionToDelegators()
        internal
        view
        returns (IDistributionToDelegators)
    {
        return
            IDistributionToDelegators(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("DistributionToDelegators"))
                )
            );
    }

    function getFtsoManager() internal view returns (IFtsoManager) {
        return
            IFtsoManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoManager"))
                )
            );
    }

    function getWNat() internal view returns (IWNat) {
        return
            IWNat(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("WNat"))
                )
            );
    }

    function getGovernanceVotePower()
        internal
        view
        returns (IGovernanceVotePower)
    {
        return
            IGovernanceVotePower(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("GovernanceVotePower"))
                )
            );
    }

    function getClaimSetupManager() internal view returns (IClaimSetupManager) {
        return
            IClaimSetupManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("ClaimSetupManager"))
                )
            );
    }

    function getValidatorRewardManager()
        internal
        view
        returns (IGenericRewardManager)
    {
        return
            IGenericRewardManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("ValidatorRewardManager"))
                )
            );
    }

    function getFlareAssetRegistry()
        internal
        view
        returns (IFlareAssetRegistry)
    {
        return
            IFlareAssetRegistry(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FlareAssetRegistry"))
                )
            );
    }

    function getValidatorRegistry() internal view returns (IValidatorRegistry) {
        return
            IValidatorRegistry(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("ValidatorRegistry"))
                )
            );
    }

    function getFlareContractRegistry()
        internal
        view
        returns (IFlareContractRegistry)
    {
        return
            IFlareContractRegistry(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FlareContractRegistry"))
                )
            );
    }

    function getAddressBinder() internal view returns (IAddressBinder) {
        return
            IAddressBinder(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("AddressBinder"))
                )
            );
    }

    function getPChainStakeMirror() internal view returns (IPChainStakeMirror) {
        return
            IPChainStakeMirror(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("PChainStakeMirror"))
                )
            );
    }

    function getPChainStakeMirrorVerifier()
        internal
        view
        returns (IPChainStakeMirrorVerifier)
    {
        return
            IPChainStakeMirrorVerifier(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("PChainStakeMirrorVerifier"))
                )
            );
    }

    function getPChainStakeMirrorMultiSigVoting()
        internal
        view
        returns (IPChainStakeMirrorMultiSigVoting)
    {
        return
            IPChainStakeMirrorMultiSigVoting(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("PChainStakeMirrorMultiSigVoting"))
                )
            );
    }

    function getRNat() internal view returns (IRNat) {
        return
            IRNat(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("RNat"))
                )
            );
    }

    function getFeeCalculator() internal view returns (IFeeCalculator) {
        return
            IFeeCalculator(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FeeCalculator"))
                )
            );
    }

    function getFtsoV2() internal view returns (FtsoV2Interface) {
        return
            FtsoV2Interface(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoV2"))
                )
            );
    }

    function getTestFtsoV2() internal view returns (TestFtsoV2Interface) {
        return
            TestFtsoV2Interface(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoV2"))
                )
            );
    }

    function getProtocolsV2() internal view returns (ProtocolsV2Interface) {
        return
            ProtocolsV2Interface(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("ProtocolsV2"))
                )
            );
    }

    function getRandomNumberV2()
        internal
        view
        returns (RandomNumberV2Interface)
    {
        return
            RandomNumberV2Interface(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("RandomNumberV2"))
                )
            );
    }

    function getRewardsV2() internal view returns (RewardsV2Interface) {
        return
            RewardsV2Interface(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("RewardsV2"))
                )
            );
    }

    function getFdcVerification() internal view returns (IFdcVerification) {
        return
            IFdcVerification(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FdcVerification"))
                )
            );
    }

    function getFdcHub() internal view returns (IFdcHub) {
        return
            IFdcHub(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FdcHub"))
                )
            );
    }

    function getFdcRequestFeeConfigurations()
        internal
        view
        returns (IFdcRequestFeeConfigurations)
    {
        return
            IFdcRequestFeeConfigurations(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FdcRequestFeeConfigurations"))
                )
            );
    }

    // END AUTO GENERATED - DO NOT EDIT ABOVE THIS LINE
}
