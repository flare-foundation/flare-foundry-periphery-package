// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

/**
 * @custom:name ConfirmedBlockHeightExists
 * @custom:id 0x02
 * @custom:supported BTC, DOGE, XRP, testBTC, testDOGE, testXRP
 * @author Flare
 * @notice The intention of this attestation type is for a dapp to be able to see what is the confirmed height of an external chain and to calculate what is the block production (time wise) in a given time range.
 * @custom:verification For the given `blockNumber`, it is checked that the block is confirmed by at least `numberOfConfirmations`.
 * If it is not, the request is rejected. We note a block on the tip of the chain is confirmed by 1 block.
 * Then `lowestQueryWindowBlock` is determined and its number and timestamp are extracted.
 *
 * Current confirmation heights consensus:
 *
 * | `Chain` | `chainId` | `numberOfConfirmations` |
 * | ------- | --------- | ----------------------- |
 * | `BTC`   | 0         | 6                       |
 * | `DOGE`  | 2         | 60                      |
 * | `XRP`   | 3         | 3                       |
 * @custom:lut `lowestQueryWindowBlockTimestamp`
 */
interface ConfirmedBlockHeightExists {
    /**
     * @notice Toplevel request
     * @param attestationType Id of the attestation type.
     * @param sourceId Id of the data source.
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
     * @notice Request body for ConfirmedBlockHeightExistsType attestation type
     * @param blockNumber The number of the block the request wants a confirmation of.
     * @param queryWindow The period in seconds for sampling. The range is from `blockNumber` to the blockNumber of the first block more than queryWindow before the `blockNumber`.
     */
    struct RequestBody {
        uint64 blockNumber;
        uint64 queryWindow;
    }

    /**
     * @notice Response body for ConfirmedBlockHeightExistsType attestation type
     * @custom:below `blockNumber`, `lowestQueryWindowBlockNumber`, `blockTimestamp` and `lowestQueryWindowBlockTimestamp` can be used to compute the average block production time in the specified block range.
     * @param blockTimestamp The timestamp of the block with `blockNumber`.
     * @param numberOfConfirmations The depth at which a block is considered confirmed depending on the chain. All attestation clients must agree on this number.
     * @param lowestQueryWindowBlockNumber The block number of the latest block that has a timestamp strictly smaller than `blockTimestamp` - `queryWindow`.
     * @param lowestQueryWindowBlockTimestamp The timestamp of the block at height `lowestQueryWindowBlockNumber`.
     */
    struct ResponseBody {
        uint64 blockTimestamp;
        uint64 numberOfConfirmations;
        uint64 lowestQueryWindowBlockNumber;
        uint64 lowestQueryWindowBlockTimestamp;
    }
}
