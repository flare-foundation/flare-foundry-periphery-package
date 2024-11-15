// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "./ProtocolsV2Interface.sol";

/**
 * FlareSystemsManager interface.
 */
interface IFlareSystemsManager is ProtocolsV2Interface {

    /// Signature structure
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// Number of weight based claims structure
    struct NumberOfWeightBasedClaims {
        uint256 rewardManagerId;
        uint256 noOfWeightBasedClaims;
    }

    /// Event emitted when random acquisition phase starts.
    event RandomAcquisitionStarted(
        uint24 indexed rewardEpochId,   // Reward epoch id
        uint64 timestamp                // Timestamp when this happened
    );

    /// Event emitted when vote power block is selected.
    event VotePowerBlockSelected(
        uint24 indexed rewardEpochId,   // Reward epoch id
        uint64 votePowerBlock,          // Vote power block for given reward epoch
        uint64 timestamp                // Timestamp when this happened
    );

    /// Event emitted when signing policy is signed.
    event SigningPolicySigned(
        uint24 indexed rewardEpochId,           // Reward epoch id
        address indexed signingPolicyAddress,   // Address which signed this
        address indexed voter,                  // Voter (entity)
        uint64 timestamp,                       // Timestamp when this happened
        bool thresholdReached                   // Indicates if signing threshold was reached
    );

    /// Event emitted when reward epoch starts.
    event RewardEpochStarted(
        uint24 indexed rewardEpochId,   // Reward epoch id
        uint32 startVotingRoundId,      // First voting round id of validity
        uint64 timestamp                // Timestamp when this happened
    );

    /// Event emitted when it is time to sign uptime vote.
    event SignUptimeVoteEnabled(
        uint24 indexed rewardEpochId,   // Reward epoch id
        uint64 timestamp                // Timestamp when this happened
    );

    /// Event emitted when uptime vote is submitted.
    event UptimeVoteSubmitted(
        uint24 indexed rewardEpochId,           // Reward epoch id
        address indexed signingPolicyAddress,   // Address which signed this
        address indexed voter,                  // Voter (entity)
        bytes20[] nodeIds,                      // Node ids with high enough uptime
        uint64 timestamp                        // Timestamp when this happened
    );

    /// Event emitted when uptime vote is signed.
    event UptimeVoteSigned(
        uint24 indexed rewardEpochId,           // Reward epoch id
        address indexed signingPolicyAddress,   // Address which signed this
        address indexed voter,                  // Voter (entity)
        bytes32 uptimeVoteHash,                 // Uptime vote hash
        uint64 timestamp,                       // Timestamp when this happened
        bool thresholdReached                   // Indicates if signing threshold was reached
    );

    /// Event emitted when rewards are signed.
    event RewardsSigned(
        uint24 indexed rewardEpochId,                       // Reward epoch id
        address indexed signingPolicyAddress,               // Address which signed this
        address indexed voter,                              // Voter (entity)
        bytes32 rewardsHash,                                // Rewards hash
        NumberOfWeightBasedClaims[] noOfWeightBasedClaims,  // Number of weight based claims list
        uint64 timestamp,                                   // Timestamp when this happened
        bool thresholdReached                               // Indicates if signing threshold was reached
    );

    /**
     * Method for collecting signatures for the new signing policy.
     * @param _rewardEpochId Reward epoch id of the new signing policy.
     * @param _newSigningPolicyHash New signing policy hash.
     * @param _signature Signature.
     */
    function signNewSigningPolicy(
        uint24 _rewardEpochId,
        bytes32 _newSigningPolicyHash,
        Signature calldata _signature
    )
        external;

    /**
     * Method for submitting node ids with high enough uptime.
     * @param _rewardEpochId Reward epoch id of the uptime vote.
     * @param _nodeIds Node ids with high enough uptime.
     * @param _signature Signature.
     */
    function submitUptimeVote(
        uint24 _rewardEpochId,
        bytes20[] calldata _nodeIds,
        Signature calldata _signature
    )
        external;

    /**
     * Method for collecting signatures for the uptime vote.
     * @param _rewardEpochId Reward epoch id of the uptime vote.
     * @param _uptimeVoteHash Uptime vote hash.
     * @param _signature Signature.
     */
    function signUptimeVote(
        uint24 _rewardEpochId,
        bytes32 _uptimeVoteHash,
        Signature calldata _signature
    )
        external;

    /**
     * Method for collecting signatures for the rewards.
     * @param _rewardEpochId Reward epoch id of the rewards.
     * @param _noOfWeightBasedClaims Number of weight based claims list.
     * @param _rewardsHash Rewards hash.
     * @param _signature Signature.
     */
    function signRewards(
        uint24 _rewardEpochId,
        NumberOfWeightBasedClaims[] calldata _noOfWeightBasedClaims,
        bytes32 _rewardsHash,
        Signature calldata _signature
    )
        external;

    /**
     * Returns the seed for given reward epoch id.
     */
    function getSeed(uint256 _rewardEpochId)
        external view
        returns(uint256);

    /**
     * Returns the threshold for given reward epoch id.
     */
    function getThreshold(uint256 _rewardEpochId)
        external view
        returns(uint16);

    /**
     * Returns voter rgistration data for given reward epoch id.
     * @param _rewardEpochId Reward epoch id.
     * @return _votePowerBlock Vote power block.
     * @return _enabled Indicates if voter registration is enabled.
     */
    function getVoterRegistrationData(
        uint256 _rewardEpochId
    )
        external view
        returns (
            uint256 _votePowerBlock,
            bool _enabled
        );

    /**
     * Indicates if voter registration is currently enabled.
     */
    function isVoterRegistrationEnabled() external view returns (bool);

    /**
     * Returns the current reward epoch id (backwards compatibility).
     */
    function getCurrentRewardEpoch() external view returns(uint256);
}
