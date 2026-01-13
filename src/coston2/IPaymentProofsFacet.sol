// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IPaymentProofsFacet
 * @notice Interface for the PaymentProofsFacet contract.
 */
interface IPaymentProofsFacet {

    /**
     * @notice Emitted when the payment proof validity duration is set.
     * @param paymentProofValidityDurationSeconds Duration in seconds.
     */
    event PaymentProofValidityDurationSecondsSet(
        uint256 paymentProofValidityDurationSeconds
    );

    /**
     * @notice Reverts if the payment proof validity duration is invalid (must be greater than 0).
     */
    error InvalidPaymentProofValidityDuration();

    /**
     * @notice Reverts if the transaction proof is invalid.
     */
    error InvalidTransactionProof();

    /**
     * @notice Reverts if the receiving address hash is invalid.
     */
    error InvalidReceivingAddressHash();

    /**
     * @notice Reverts if the source ID is invalid.
     */
    error InvalidSourceId();

    /**
     * @notice Reverts if the transaction status is invalid.
     */
    error InvalidTransactionStatus();

    /**
     * @notice Reverts if the source address and XRPL address do not match.
     */
    error MismatchingSourceAndXrplAddr();

    /**
     * @notice Reverts if the payment proof has expired.
     */
    error PaymentProofExpired();

    /**
     * @notice Gets the source ID used for payment verification.
     * @return The source ID.
     */
    function getSourceId()
        external view
        returns (bytes32);

    /**
     * @notice Gets the payment proof validity duration in seconds.
     * @return The payment proof validity duration in seconds.
     */
    function getPaymentProofValidityDurationSeconds()
        external view
        returns (uint256);
}