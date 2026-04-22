// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IMemoInstructionsFacet
 * @notice Interface for the MemoInstructionsFacet contract.
 */
interface IMemoInstructionsFacet {

    /**
     * @notice Emitted when a memo user operation is executed.
     * @param personalAccount The personal account address.
     * @param nonce The nonce of the memo instruction.
     */
    event UserOperationExecuted(
        address indexed personalAccount,
        uint256 nonce
    );

    /**
     * @notice Emitted when ignoreMemo flag is set for a target transaction.
     * @param personalAccount The personal account address.
     * @param targetTxId The target transaction ID to ignore memo for.
     */
    event IgnoreMemoSet(
        address indexed personalAccount,
        bytes32 indexed targetTxId
    );

    /**
     * @notice Emitted when a personal account's nonce is increased.
     * @param personalAccount The personal account address.
     * @param newNonce The new nonce value.
     */
    event NonceIncreased(
        address indexed personalAccount,
        uint256 newNonce
    );

    /**
     * @notice Emitted when a PA executor is set.
     * @param personalAccount The personal account address.
     * @param executor The executor address.
     */
    event ExecutorSet(
        address indexed personalAccount,
        address indexed executor
    );

    /**
     * @notice Emitted when a PA executor is removed.
     * @param personalAccount The personal account address.
     */
    event ExecutorRemoved(
        address indexed personalAccount
    );

    /**
     * @notice Emitted when a replacement fee is set for a stuck transaction.
     * @param personalAccount The personal account address.
     * @param targetTxId The target transaction ID.
     * @param newFee The replacement fee.
     */
    event ReplacementFeeSet(
        address indexed personalAccount,
        bytes32 indexed targetTxId,
        uint64 newFee
    );

    /**
     * @notice Emitted when direct minting is executed.
     * @param personalAccount The personal account address.
     * @param transactionId The XRPL transaction ID.
     * @param sourceAddress The XRPL source address.
     * @param amount The total minted amount.
     * @param executorFee The fee paid to the executor.
     * @param executor The executor address.
     */
    event DirectMintingExecuted(
        address indexed personalAccount,
        bytes32 indexed transactionId,
        string sourceAddress,
        uint256 amount,
        uint256 executorFee,
        address executor
    );

    /**
     * @notice Reverts if the transaction has already been executed.
     */
    error TransactionAlreadyExecuted();

    /**
     * @notice Reverts if the address is zero.
     */
    error AddressZero();

    /**
     * @notice Reverts if the value is zero.
     */
    error ValueZero();

    /**
     * @notice Reverts if the nonce doesn't match expected value.
     * @param expected The expected nonce value.
     * @param actual The actual nonce value provided.
     */
    error InvalidNonce(
        uint256 expected,
        uint256 actual
    );

    /**
     * @notice Reverts if the userOp sender doesn't match the personal account.
     * @param sender The sender from the PackedUserOperation.
     * @param personalAccount The expected personal account address.
     */
    error InvalidSender(
        address sender,
        address personalAccount
    );

    /**
     * @notice Reverts if the memo instruction call fails.
     * @param returnData The return data from the failed call.
     */
    error CallFailed(
        bytes returnData
    );

    /**
     * @notice Reverts if the caller is not the AssetManager.
     */
    error OnlyAssetManager();

    /**
     * @notice Reverts if the minted amount is insufficient to cover the executor fee.
     * @param amount The minted amount.
     * @param fee The executor fee.
     */
    error InsufficientAmountForFee(
        uint256 amount,
        uint256 fee
    );

    /**
     * @notice Reverts if the executor doesn't match the PA's executor.
     * @param expected The expected executor address.
     * @param actual The actual executor address.
     */
    error WrongExecutor(
        address expected,
        address actual
    );

    /**
     * @notice Reverts if the memo data is invalid.
     */
    error InvalidMemoData();

    /**
     * @notice Reverts if the memo instruction ID is not supported.
     * @param instructionId The unsupported instruction ID.
     */
    error InvalidInstructionId(
        uint8 instructionId
    );

    /**
     * @notice Reverts if the new nonce is invalid.
     * @param currentNonce The current nonce value.
     * @param newNonce The requested new nonce value.
     */
    error InvalidNonceIncrease(
        uint256 currentNonce,
        uint256 newNonce
    );

    /**
     * @notice Called by the AssetManager when FAssets are minted via direct minting.
     * FAssets are transferred to the MasterAccountController before this call.
     * @param _transactionId The XRPL transaction ID.
     * @param _sourceAddress The XRPL source address (minter).
     * @param _amount The minted FAsset amount.
     * @param _underlyingTimestamp The XRPL transaction timestamp.
     * @param _memoData The raw XRPL memo bytes.
     * @param _executor The executor address.
     */
    function mintedFAssets(
        bytes32 _transactionId,
        string calldata _sourceAddress,
        uint256 _amount,
        uint256 _underlyingTimestamp,
        bytes calldata _memoData,
        address payable _executor
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
     * @notice Returns the current memo instruction nonce for a personal account.
     * @param _personalAccount The personal account address.
     * @return The current nonce.
     */
    function getNonce(
        address _personalAccount
    )
        external view
        returns (uint256);

    /**
     * @notice Returns the executor for a personal account.
     * @param _personalAccount The personal account address.
     * @return The executor address (address(0) if not set).
     */
    function getExecutor(
        address _personalAccount
    )
        external view
        returns (address);
}
