// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

/**
 * @custom:name EVMTransaction
 * @custom:id 0x06
 * @custom:supported ETH, FLR, SGB, testETH, testFLR, testSGB
 * @author Flare
 * @notice The purpose of this type is to relay transactions from an evm chain to FLARE chain.
 * This type is only relevant for the evm-compatible chains.
 * @custom:verification If transaction with `transactionId` is contained a block on main branch with at least `requiredConfirmations`, the specified data is relayed.
 * If an indicated event does not exist, the request is rejected.
 * @custom:lut `timestamp`
 */
interface EVMTransaction {
    /**
     * @notice Toplevel request
     * @param attestationType Attestation type id as defined for each attestation type on [this repo](https://gitlab.com/flarenetwork/state-connector-protocol/)
     * @param sourceId  Id of the data source.
     * @param messageIntegrityCode `MessageIntegrityCode` that is derived from the expected response as defined [here](/specs/attestations/hash-MIC.md#message-integrity-code).
     * @param requestBody Data defining the request. Type (struct) and interpretation is determined by the `attestationType`.
     */
    struct Request {
        bytes32 attestationType;
        bytes32 sourceId;
        bytes32 messageIntegrityCode;
        RequestBody requestBody;
    }

    /**
     * @notice Toplevel response
     * @param attestationType Extracted from the request.
     * @param sourceId Extracted from the request.
     * @param votingRound The id of the state connector round in which the request was considered.
     * @param lowestUsedTimestamp The lowest timestamp used to generate the response.
     * @param requestBody Extracted from the request.
     * @param responseBody Data defining the response. The verification rules for the construction of the response body and the type are defined per specific `attestationType`.
     */
    struct Response {
        bytes32 attestationType;
        bytes32 sourceId;
        uint64 votingRound;
        uint64 lowestUsedTimestamp;
        RequestBody requestBody;
        ResponseBody responseBody;
    }

    /**
     * @notice Toplevel proof
     * @param merkleProof Merkle proof corresponding to the attestation response.
     * @param data Attestation response.
     */
    struct Proof {
        bytes32[] merkleProof;
        Response data;
    }

    /**
     * @notice Request body for EVM transaction attestation type
     * @custom:below Note that events (logs) are indexed in block not in each transaction. The contract that uses the attestation should specify the order of event logs as needed and the requestor should sort `logIndices`
     * with respect to the set specifications. If possible, the contact should only require one `logIndex`.
     * @param transactionHash Hash of the transaction(transactionHash).
     * @param requiredConfirmations The height at which a block is considered confirmed by the requestor.
     * @param provideInput If true, "input" field is included in the response.
     * @param listEvents If true, events indicated by `logIndices` are included in the response. Otherwise, no events are included in the response.
     * @param logIndices If listEvents is false, this should be an empty list, otherwise, the request is rejected. If listEvents is true, this is the list of indices (logIndex) of the events to be relayed (sorted by the requestor). The array should contain at most 50 indices. If empty, it indicates all events in order capped by 50.
     */
    struct RequestBody {
        bytes32 transactionHash;
        uint16 requiredConfirmations;
        bool provideInput;
        bool listEvents;
        uint32[] logIndices;
    }

    /**
     * @notice Response body for EVM transaction attestation type
     * @custom:below Some field description are elaborated [here](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_gettransactionbyhash).
     * @param blockNumber Number of the block in which the transaction is included.
     * @param timestamp Timestamp of the block in which the transaction is included.
     * @param sourceAddress The address (from) that signed the transaction.
     * @param isDeployment Indicate whether it is a contract creation transaction.
     * @param receivingAddress The address (to) of the receiver of the initial transaction. Zero address if `isDeployment` is true.
     * @param value The value transferred by the initial transaction in wei.
     * @param input If `provideInput`, this is the data send along with the initial transaction. Otherwise it is the default value `0x00`.
     * @param status Status of the transaction 1 - success, 0 - failure.
     * @param events If `listEvents` is true, an array of the requested events. Sorted by the logIndex in the same order as `logIndices`. Otherwise, an empty array.
     */
    struct ResponseBody {
        uint64 blockNumber;
        uint64 timestamp;
        address sourceAddress;
        bool isDeployment;
        address receivingAddress;
        uint256 value;
        bytes input;
        uint8 status;
        Event[] events;
    }

    /**
     * @notice Event log record
     * @custom:above An `Event` is a struct with the following fields:
     * @custom:below For additional description of event log, see [here](https://ethereum.org/en/developers/docs/apis/json-rpc/#eth_getfilterchanges).
     * @param logIndex The consecutive number of the event in block.
     * @param emitterAddress The address of the contract that emitted the event.
     * @param topics An array of up to 4 32-byte strings of indexed log arguments. The first string is the signature of the event.
     * @param data Concatenated 32-byte strings of non-indexed log arguments. At least 32 bytes long.
     * @param removed It is true if log was removed due to a chain reorganization and false if it is a valid log.
     */
    struct Event {
        uint32 logIndex;
        address emitterAddress;
        bytes32[] topics;
        bytes data;
        bool removed;
    }
}
