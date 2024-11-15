// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

/**
 * @custom:name AddressValidity
 * @custom:id 0x05
 * @custom:supported BTC, DOGE, XRP, testBTC, testDOGE, testXRP
 * @author Flare
 * @notice An assertion whether a string represents a valid address on an external chain.
 * @custom:verification The address is checked against all validity criteria of the chain with `sourceId`.
 * Indicator of validity is provided.
 * If the address is valid, its standard form and standard hash are computed.
 * Validity criteria for each supported chain:
 * - [BTC](/specs/attestations/external-chains/address-validity/BTC.md)
 * - [DOGE](/specs/attestations/external-chains/address-validity/DOGE.md)
 * - [XRPL](/specs/attestations/external-chains/address-validity/XRPL.md)
 * @custom:lut `0xffffffffffffffff` ($2^{64}-1$ in hex)
 */
interface AddressValidity {
    /**
     * @notice Toplevel request
     * @param attestationType ID of the attestation type.
     * @param sourceId Id of the data source.
     * @param messageIntegrityCode `MessageIntegrityCode` that is derived from the expected response.
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
     * @param votingRound The ID of the State Connector round in which the request was considered.
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
     * @notice Request body for AddressValidity attestation type
     * @param addressStr Address to be verified.
     */
    struct RequestBody {
        string addressStr;
    }

    /**
     * @notice Response body for AddressValidity attestation type
     * @param isValid Boolean indicator of the address validity.
     * @param standardAddress If `isValid`, standard form of the validated address. Otherwise an empty string.
     * @param standardAddressHash If `isValid`, standard address hash of the validated address. Otherwise a zero bytes32 string.
     */
    struct ResponseBody {
        bool isValid;
        string standardAddress;
        bytes32 standardAddressHash;
    }
}
