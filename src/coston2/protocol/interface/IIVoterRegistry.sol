// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "../../IVoterRegistry.sol";

/**
 * VoterRegistry internal interface.
 */
interface IIVoterRegistry is IVoterRegistry {

    /**
     * Enables automatic voter registration triggered by system registration contract.
     * @param _voter The voter address.
     * @dev Only system registration contract can call this method.
     */
    function systemRegistration(address _voter) external;

    /**
     * Sets new signing policy initialisation start block number for a given reward epoch.
     * @param _rewardEpochId The reward epoch id.
     * @dev Only FlareSystemsManager contract can call this method.
     */
    function setNewSigningPolicyInitializationStartBlockNumber(uint256 _rewardEpochId) external;

    /**
     * Creates signing policy snapshot and returns the list of registered signing policy addresses
     * and normalised weights for a given reward epoch.
     * @param _rewardEpochId The reward epoch id.
     * @dev Only FlareSystemsManager contract can call this method.
     */
    function createSigningPolicySnapshot(uint256 _rewardEpochId)
        external
        returns (
            address[] memory _signingPolicyAddresses,
            uint16[] memory _normalisedWeights,
            uint16 _normalisedWeightsSum
        );

/**
     * Returns the list of registered voters' delegation addresses for a given reward epoch (vote power block).
     * @param _rewardEpochId The reward epoch id.
     */
    function getRegisteredDelegationAddresses(
        uint256 _rewardEpochId
    )
        external view
        returns (address[] memory _delegationAddresses);

    /**
     * Returns the list of registered voters' data provider addresses for a given reward epoch (snapshot block).
     * @param _rewardEpochId The reward epoch id.
     */
    function getRegisteredSubmitAddresses(
        uint256 _rewardEpochId
    )
        external view
        returns (address[] memory);

    /**
     * Returns the list of registered voters' deposit signatures addresses for a given reward epoch (snapshot block).
     * @param _rewardEpochId The reward epoch id.
     */
    function getRegisteredSubmitSignaturesAddresses(
        uint256 _rewardEpochId
    )
        external view
        returns (address[] memory _signingPolicyAddresses);

    /**
     * Returns the list of registered voters' signing policy addresses for a given reward epoch (snapshot block).
     * @param _rewardEpochId The reward epoch id.
     */
    function getRegisteredSigningPolicyAddresses(
        uint256 _rewardEpochId
    )
        external view
        returns (address[] memory _signingPolicyAddresses);

    /**
     * Returns the list of registered voters' public keys (parts1 and parts2)
     * for a given reward epoch (snapshot block).
     * @param _rewardEpochId The reward epoch id.
     * @return _parts1 The first parts of the public keys.
     * @return _parts2 The second parts of the public keys.
     */
    function getRegisteredPublicKeys(
        uint256 _rewardEpochId
    )
        external view
        returns (bytes32[] memory _parts1, bytes32[] memory _parts2);

    /**
     * Returns the list of registered voters' node ids for a given reward epoch (vote power block).
     * @param _rewardEpochId The reward epoch id.
     */
    function getRegisteredNodeIds(
        uint256 _rewardEpochId
    )
        external view
        returns (bytes20[][] memory _nodeIds);

    /**
     * Returns the list of registered voters' addresses and their registration weights for a given reward epoch.
     * It returns empty lists if the reward epoch is not supported.
     * @param _rewardEpochId The reward epoch id.
     * @return _voters The voters' addresses.
     * @return _registrationWeights The registration weights.
     */
    function getRegisteredVotersAndRegistrationWeights(
        uint256 _rewardEpochId
    )
        external view
        returns (
            address[] memory _voters,
            uint256[] memory _registrationWeights
        );

    /**
     * Returns the list of registered voters' addresses and their normalised weights for a given reward epoch.
     * @param _rewardEpochId The reward epoch id.
     * @return _voters The voters' addresses.
     * @return _normalisedWeights The normalised weights.
     */
    function getRegisteredVotersAndNormalisedWeights(
        uint256 _rewardEpochId
    )
        external view
        returns (
            address[] memory _voters,
            uint16[] memory _normalisedWeights
        );

    /**
     * Returns voter's address and normalised weight for a given reward epoch and signing policy address.
     * @param _rewardEpochId The reward epoch id.
     * @param _signingPolicyAddress The signing policy address of the voter.
     * @return _voter The voter address.
     * @return _normalisedWeight The normalised weight of the voter.
     */
    function getVoterWithNormalisedWeight(
        uint256 _rewardEpochId,
        address _signingPolicyAddress
    )
        external view
        returns (
            address _voter,
            uint16 _normalisedWeight
        );

    /**
     * Returns voter's public key and normalised weight for a given reward epoch and signing policy address.
     * @param _rewardEpochId The reward epoch id.
     * @param _signingPolicyAddress The signing policy address.
     * @return _publicKeyPart1 The first part of the public key.
     * @return _publicKeyPart2 The second part of the public key.
     * @return _normalisedWeight The normalised weight of the voter.
     * @return _normalisedWeightsSumOfVotersWithPublicKeys The normalised weights sum of voters with public keys.
     */
    function getPublicKeyAndNormalisedWeight(
        uint256 _rewardEpochId,
        address _signingPolicyAddress
    )
        external view
        returns (
            bytes32 _publicKeyPart1,
            bytes32 _publicKeyPart2,
            uint16 _normalisedWeight,
            uint16 _normalisedWeightsSumOfVotersWithPublicKeys
        );

    /**
     * Returns registration weight for a given reward epoch and voter address.
     * It reverts if the voter is not registered.
     * @param _voter The voter address.
     * @param _rewardEpochId The reward epoch id.
     * @return _registrationWeight The registration weight.
     */
    function getVoterRegistrationWeight(
        address _voter,
        uint256 _rewardEpochId
    )
        external view returns (uint256 _registrationWeight);

    /**
     * Returns normalised weight for a given reward epoch and voter address.
     * It reverts if the voter is not registered or snapshot was not created yet.
     * @param _voter The voter address.
     * @param _rewardEpochId The reward epoch id.
     * @return _normalisedWeight The normalised weight.
     */
    function getVoterNormalisedWeight(
        address _voter,
        uint256 _rewardEpochId
    )
        external view returns (uint16 _normalisedWeight);

    /**
     * Returns weights sums for a given reward epoch.
     * @param _rewardEpochId The reward epoch id.
     * @return _weightsSum The weights sum.
     * @return _normalisedWeightsSum The normalised weights sum.
     * @return _normalisedWeightsSumOfVotersWithPublicKeys The normalised weights sum of voters with public keys.
     */
    function getWeightsSums(uint256 _rewardEpochId)
        external view
        returns (
            uint128 _weightsSum,
            uint16 _normalisedWeightsSum,
            uint16 _normalisedWeightsSumOfVotersWithPublicKeys
        );
}
