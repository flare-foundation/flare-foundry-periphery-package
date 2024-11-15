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
import {IPollingFtso} from "./IPollingFtso.sol";
import {IAddressBinder} from "./IAddressBinder.sol";
import {IPChainStakeMirror} from "./IPChainStakeMirror.sol";
import {IPChainStakeMirrorVerifier} from "./IPChainStakeMirrorVerifier.sol";
import {IPChainStakeMirrorMultiSigVoting} from "./IPChainStakeMirrorMultiSigVoting.sol";
import {ISubmission} from "./ISubmission.sol";
import {IEntityManager} from "./IEntityManager.sol";
import {IVoterRegistry} from "./IVoterRegistry.sol";
import {IFlareSystemsCalculator} from "./IFlareSystemsCalculator.sol";
import {IFlareSystemsManager} from "./IFlareSystemsManager.sol";
import {IRewardManager} from "./IRewardManager.sol";
import {IRelay} from "./IRelay.sol";
import {IWNatDelegationFee} from "./IWNatDelegationFee.sol";
import {IFtsoInflationConfigurations} from "./IFtsoInflationConfigurations.sol";
import {IFtsoRewardOffersManager} from "./IFtsoRewardOffersManager.sol";
import {IFtsoFeedDecimals} from "./IFtsoFeedDecimals.sol";
import {IFtsoFeedPublisher} from "./IFtsoFeedPublisher.sol";
import {IFtsoFeedIdConverter} from "./IFtsoFeedIdConverter.sol";
import {IFastUpdateIncentiveManager} from "./IFastUpdateIncentiveManager.sol";
import {IFastUpdater} from "./IFastUpdater.sol";
import {IFastUpdatesConfiguration} from "./IFastUpdatesConfiguration.sol";
import {IRNat} from "./IRNat.sol";
import {IFeeCalculator} from "./IFeeCalculator.sol";
import {FtsoV2Interface} from "./FtsoV2Interface.sol";
import {TestFtsoV2Interface} from "./TestFtsoV2Interface.sol";
import {ProtocolsV2Interface} from "./ProtocolsV2Interface.sol";
import {RandomNumberV2Interface} from "./RandomNumberV2Interface.sol";
import {RewardsV2Interface} from "./RewardsV2Interface.sol";
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

    function getPollingFtso() internal view returns (IPollingFtso) {
        return
            IPollingFtso(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("PollingFtso"))
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

    function getSubmission() internal view returns (ISubmission) {
        return
            ISubmission(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("Submission"))
                )
            );
    }

    function getEntityManager() internal view returns (IEntityManager) {
        return
            IEntityManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("EntityManager"))
                )
            );
    }

    function getVoterRegistry() internal view returns (IVoterRegistry) {
        return
            IVoterRegistry(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("VoterRegistry"))
                )
            );
    }

    function getFlareSystemsCalculator()
        internal
        view
        returns (IFlareSystemsCalculator)
    {
        return
            IFlareSystemsCalculator(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FlareSystemsCalculator"))
                )
            );
    }

    function getFlareSystemsManager()
        internal
        view
        returns (IFlareSystemsManager)
    {
        return
            IFlareSystemsManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FlareSystemsManager"))
                )
            );
    }

    function getRewardManager() internal view returns (IRewardManager) {
        return
            IRewardManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("RewardManager"))
                )
            );
    }

    function getRelay() internal view returns (IRelay) {
        return
            IRelay(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("Relay"))
                )
            );
    }

    function getWNatDelegationFee() internal view returns (IWNatDelegationFee) {
        return
            IWNatDelegationFee(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("WNatDelegationFee"))
                )
            );
    }

    function getFtsoInflationConfigurations()
        internal
        view
        returns (IFtsoInflationConfigurations)
    {
        return
            IFtsoInflationConfigurations(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoInflationConfigurations"))
                )
            );
    }

    function getFtsoRewardOffersManager()
        internal
        view
        returns (IFtsoRewardOffersManager)
    {
        return
            IFtsoRewardOffersManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoRewardOffersManager"))
                )
            );
    }

    function getFtsoFeedDecimals() internal view returns (IFtsoFeedDecimals) {
        return
            IFtsoFeedDecimals(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoFeedDecimals"))
                )
            );
    }

    function getFtsoFeedPublisher() internal view returns (IFtsoFeedPublisher) {
        return
            IFtsoFeedPublisher(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoFeedPublisher"))
                )
            );
    }

    function getFtsoFeedIdConverter()
        internal
        view
        returns (IFtsoFeedIdConverter)
    {
        return
            IFtsoFeedIdConverter(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FtsoFeedIdConverter"))
                )
            );
    }

    function getFastUpdateIncentiveManager()
        internal
        view
        returns (IFastUpdateIncentiveManager)
    {
        return
            IFastUpdateIncentiveManager(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FastUpdateIncentiveManager"))
                )
            );
    }

    function getFastUpdater() internal view returns (IFastUpdater) {
        return
            IFastUpdater(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FastUpdater"))
                )
            );
    }

    function getFastUpdatesConfiguration()
        internal
        view
        returns (IFastUpdatesConfiguration)
    {
        return
            IFastUpdatesConfiguration(
                FLARE_CONTRACT_REGISTRY.getContractAddressByHash(
                    keccak256(abi.encode("FastUpdatesConfiguration"))
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

    // END AUTO GENERATED - DO NOT EDIT ABOVE THIS LINE
}
