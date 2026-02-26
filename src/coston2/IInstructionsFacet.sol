// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IPayment} from "./IPayment.sol";

/**
 * @title IInstructionsFacet
 * @notice Interface for the InstructionsFacet contract.
 */
interface IInstructionsFacet {

     /**
     * @notice Emitted when collateral is reserved for minting.
     * @param personalAccount The personal account address.
     * @param transactionId The transaction ID.
     * @param paymentReference The payment reference.
     * @param xrplOwner The XRPL owner address.
     * @param collateralReservationId The collateral reservation ID.
     * @param agentVault The agent vault address.
     * @param lots The number of lots reserved.
     * @param executor The executor address.
     * @param executorFee The fee paid to the executor.
     */
    event CollateralReserved(
        address indexed personalAccount,
        bytes32 indexed transactionId,
        bytes32 indexed paymentReference,
        string xrplOwner,
        uint256 collateralReservationId,
        address agentVault,
        uint256 lots,
        address executor,
        uint256 executorFee
    );

    /**
     * @notice Emitted when an instruction is executed.
     * @param personalAccount The personal account address.
     * @param transactionId The transaction ID.
     * @param paymentReference The payment reference.
     * @param xrplOwner The XRPL owner address.
     * @param instructionId The instruction ID.
     */
    event InstructionExecuted(
        address indexed personalAccount,
        bytes32 indexed transactionId,
        bytes32 indexed paymentReference,
        string xrplOwner,
        uint256 instructionId
    );

    /**
     * @notice Emitted when a FXRP redeem operation is performed.
     * @param personalAccount The personal account address.
     * @param lots The number of lots redeemed.
     * @param amount The amount redeemed.
     * @param executor The executor address.
     * @param executorFee The fee paid to the executor.
     */
    event FXrpRedeemed(
        address indexed personalAccount,
        uint256 lots,
        uint256 amount,
        address executor,
        uint256 executorFee
    );

    /**
     * @notice Emitted when a transfer of FXRP is made.
     * @param personalAccount The personal account address.
     * @param to The recipient address.
     * @param amount The amount of FXRP transferred.
     */
    event FXrpTransferred(
        address indexed personalAccount,
        address to,
        uint256 amount
    );

    /**
     * @notice Emitted when a token approval is made for a vault.
     * @param personalAccount The personal account address.
     * @param fxrp The FXRP token address.
     * @param vault The vault address.
     * @param amount The approved amount.
     */
    event Approved(
        address indexed personalAccount,
        address fxrp,
        address vault,
        uint256 amount
    );

    /**
     * @notice Emitted when a deposit is made to a vault.
     * @param personalAccount The personal account address.
     * @param vault The vault address.
     * @param amount The amount deposited.
     * @param shares The number of shares received.
     */
    event Deposited(
        address indexed personalAccount,
        address indexed vault,
        uint256 amount,
        uint256 shares
    );

    /**
     * @notice Emitted when a redeem is made from a vault.
     * @param personalAccount The personal account address.
     * @param vault The vault address.
     * @param shares The number of shares to redeem.
     * @param amount The amount to redeem.
     */
    event Redeemed(
        address indexed personalAccount,
        address indexed vault,
        uint256 shares,
        uint256 amount
    );

    /**
     * @notice Emitted when a withdrawal claim is made.
     * @param personalAccount The personal account address.
     * @param vault The vault address.
     * @param period The period for which the claim is made.
     * @param amount The amount claimed.
     */
    event WithdrawalClaimed(
        address indexed personalAccount,
        address indexed vault,
        uint256 period,
        uint256 amount
    );

    /**
     * @notice Emitted when a redeem request is made.
     * @param personalAccount The personal account address.
     * @param vault The vault address.
     * @param shares The number of shares to redeem.
     * @param claimableEpoch The epoch when the claim becomes available.
     * @param year The year of the claimable date.
     * @param month The month of the claimable date.
     * @param day The day of the claimable date.
     */
    event RedeemRequested(
        address indexed personalAccount,
        address indexed vault,
        uint256 shares,
        uint256 claimableEpoch,
        uint256 year,
        uint256 month,
        uint256 day
    );

    /**
     * @notice Emitted when a claim is made for a specific date.
     * @param personalAccount The personal account address.
     * @param vault The vault address.
     * @param year The year of the claim.
     * @param month The month of the claim.
     * @param day The day of the claim.
     * @param shares The number of shares claimed.
     * @param amount The amount claimed.
     */
    event Claimed(
        address indexed personalAccount,
        address indexed vault,
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 shares,
        uint256 amount
    );

    /**
     * @notice Reverts if the payment amount is invalid.
     * @param requiredAmount The required payment amount.
     */
    error InvalidPaymentAmount(
        uint256 requiredAmount
    );

    /**
     * @notice Reverts if the transaction has already been executed.
     */
    error TransactionAlreadyExecuted();

    /**
     * @notice Reverts if the transaction ID is invalid.
     */
    error InvalidTransactionId();

    /**
     * @notice Reverts if the instruction is invalid.
     * @param instructionType The invalid instruction type.
     * @param instructionCommand The invalid instruction command.
     */
    error InvalidInstruction(
        uint256 instructionType,
        uint256 instructionCommand
    );

    /**
     * @notice Reverts if the instruction type is invalid.
     * @param instructionType The invalid instruction type.
     */
    error InvalidInstructionType(
        uint256 instructionType
    );

    /**
     * @notice Reverts if the value is zero.
     */
    error ValueZero();

    /**
     * @notice Reverts if the address is zero.
     */
    error AddressZero();

    /**
     * @notice Reverts if the collateral reservation ID is unknown.
     */
    error UnknownCollateralReservationId();

    /**
     * @notice Reverts if minting is not completed.
     */
    error MintingNotCompleted();

    /**
     * @notice Reverts if the amount is invalid.
     */
    error InvalidAmount();

    /**
     * @notice Reverts if the minter is invalid.
     */
    error InvalidMinter();

    /**
     * @notice Reserve collateral for minting operation.
     * @param _xrplAddress The XRPL address requesting the collateral reservation.
     * @param _paymentReference The payment reference associated with the request.
     * @param _transactionId The unique transaction ID for tracking.
     * @return _collateralReservationId The ID of the collateral reservation.
     */
    function reserveCollateral(
        string calldata _xrplAddress,
        bytes32 _paymentReference,
        bytes32 _transactionId
    )
        external payable
        returns (uint256 _collateralReservationId);

    /**
     * @notice Execute deposit after successful minting for _collateralReservationId.
     * @param _collateralReservationId The ID of the collateral reservation request returned
       by `reserveCollateral` call.
     * @param _proof Proof of XRPL transaction.
     * @param _xrplAddress The XRPL address requesting execution.
     */
    function executeDepositAfterMinting(
        uint256 _collateralReservationId,
        IPayment.Proof calldata _proof,
        string calldata _xrplAddress
    )
        external;

    /**
     * @notice Execute an XRPL instruction for a given XRPL address.
     * @param _proof Proof of XRPL transaction.
     * @param _xrplAddress The XRPL address requesting execution.
     */
    function executeInstruction(
        IPayment.Proof calldata _proof,
        string calldata _xrplAddress
    )
        external payable;

    /**
     * @notice Returns true if the transaction id has already been used.
     * @param _transactionId The transaction id to check.
     * @return True if used, false otherwise.
     */
    function isTransactionIdUsed(
        bytes32 _transactionId
    )
        external view
        returns (bool);

    /**
     * @notice Returns the transaction id for a given collateral reservation id.
     * @param _collateralReservationId The collateral reservation id.
     * @return _transactionId The transaction id associated with the collateral reservation.
     */
    function getTransactionIdForCollateralReservation(
        uint256 _collateralReservationId
    )
        external view
        returns (bytes32 _transactionId);
}