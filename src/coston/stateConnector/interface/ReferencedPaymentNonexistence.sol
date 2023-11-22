// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

/**
 * @custom:name ReferencedPaymentNonexistence
 * @custom:id 0x04
 * @custom:supported BTC, DOGE, XRP, testBTC, testDOGE, testXRP
 * @author Flare
 * @notice The purpose of this type of attestation is to prove that an agreed payment has not been made, hence, give grounds to liquidate some funds locked by a smart contract on Flare.
 * A confirmed request shows that a transaction meeting certain criteria (address, amount, reference) did not appear in the specified block range.
 * @custom:verification Let `firstOverflowBlock` be the first block that has the block number higher than `deadlineBlockNumber` and the timestamp later than `deadlineTimestamp`.
 * If `firstOverflowBlock` cannot be determined or does not have a sufficient [number of confirmations](/specs/attestations/configs.md#finalityconfirmation), the attestation request is rejected.
 * If `firstOverflowBlockNumber` is higher or equal to `minimalBlockNumber`, the request is rejected.
 * The search range are blocks between heights (including) `minimalBlockNumber` and (excluding) `firstOverflowBlockNumber`.
 * If the verifier does not have a view on all blocks from `minimalBlockNumber` to `firstOverflowBlockNumber`, the attestation request should be rejected.
 *
 * The request is confirmed if no transaction meeting the specified criteria is found in the search range.
 * The criteria are chain specific.
 * ### UTXO (Bitcoin and Dogecoin)
 *
 * - it is not coinbase transaction,
 * - the transaction has the specified [standardPaymentReference](/specs/attestations/external-chains/standardPaymentReference.md#btc-and-doge-blockchains),
 * - the sum of values of all outputs with the specified address minus the sum of values of all inputs with the specified address is greater than `amount` (in practice the sum of all values of the inputs with the specified address is zero).
 *
 *
 * ### XRP
 *
 * - the transaction is of type payment,
 * - the transaction has the specified [standardPaymentReference](/specs/attestations/external-chains/standardPaymentReference.md#xrp),
 * - one of the following must holds:
 *   - transaction status is success and the amount received by the specified destination address is greater than the specified `value`,
 *   - transaction status is failure by receiver's fault and the specified destination address would receive amount greater than the specified `value` had the transaction been successful.
 * @custom:lut `minimalBlockTimestamp`
 */
interface ReferencedPaymentNonexistence {
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
     * @notice Request body for ReferencePaymentNonexistence attestation type
     * @param minimalBlockNumber The start block of the search range.
     * @param deadlineBlockNumber The blockNumber to be included in the search range.
     * @param deadlineTimestamp The timestamp to be included in the search range.
     * @param destinationAddressHash The standard address hash of the address to which the payment had to be done.
     * @param amount The requested amount in minimal units that had to be payed.
     * @param standardPaymentReference The requested standard payment reference.
     * @custom:below The `standardPaymentReference` should not be zero (as 32-byte sequence).
     */
    struct RequestBody {
        uint64 minimalBlockNumber;
        uint64 deadlineBlockNumber;
        uint64 deadlineTimestamp;
        bytes32 destinationAddressHash;
        uint256 amount;
        bytes32 standardPaymentReference;
    }

    /**
     * @notice Response body for ReferencePaymentNonexistence attestation type.
     * @param minimalBlockTimestamp The timestamp of the minimalBlock.
     * @param firstOverflowBlockNumber The height of the firstOverflowBlock.
     * @param firstOverflowBlockTimestamp The timestamp of the firstOverflowBlock.
     * @custom:below `firstOverflowBlock` is the first block that has block number higher than `deadlineBlockNumber` and timestamp later than `deadlineTimestamp`.
     * The specified search range are blocks between heights (including) `minimalBlockNumber` and (excluding) `firstOverflowBlockNumber`.
     */
    struct ResponseBody {
        uint64 minimalBlockTimestamp;
        uint64 firstOverflowBlockNumber;
        uint64 firstOverflowBlockTimestamp;
    }
}
