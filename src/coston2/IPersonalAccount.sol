// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IPersonalAccountBase} from "./IPersonalAccountBase.sol";

/**
 * @title IPersonalAccount
 * @notice Interface for PersonalAccount contract.
 */
interface IPersonalAccount is IPersonalAccountBase {
    /// @notice Struct containing call information for executeUserOp
    struct Call {
        /// @notice Target contract address
        address target;
        /// @notice value (in wei) to send with the call
        uint256 value;
        /// @notice Call data
        bytes data;
    }
    /**
     * @notice Emitted when collateral is reserved for minting.
     * @param agentVault The agent vault address.
     * @param lots The number of lots that will be minted.
     * @param executor The executor address.
     * @param executorFee The fee paid to the executor.
     * @param collateralReservationId The ID of the collateral reservation.
     */
    event CollateralReserved(
        address agentVault,
        uint256 lots,
        address executor,
        uint256 executorFee,
        uint256 collateralReservationId
    );

    /**
     * @notice Emitted when a transfer of FXRP is made.
     * @param to The recipient address.
     * @param amount The amount of FXRP transferred.
     */
    event FXrpTransferred(
        address to,
        uint256 amount
    );

    /**
     * @notice Emitted when a FXRP redeem operation is performed.
     * @param lots The number of lots redeemed.
     * @param amount The amount redeemed.
     * @param executor The executor address.
     * @param executorFee The fee paid to the executor.
     */
    event FXrpRedeemed(
        uint256 lots,
        uint256 amount,
        address executor,
        uint256 executorFee
    );

    /**
     * @notice Emitted when a token approval is made for a vault.
     * @param fxrp The FXRP token address.
     * @param vault The vault address.
     * @param amount The approved amount.
     */
    event Approved(
        address fxrp,
        address vault,
        uint256 amount
    );

    /**
     * @notice Emitted when a deposit is made to a vault.
     * @param vault The vault address.
     * @param amount The amount deposited.
     * @param shares The number of shares received.
     */
    event Deposited(
        address indexed vault,
        uint256 amount,
        uint256 shares
    );

    /**
     * @notice Emitted when a redeem is made from a vault.
     * @param vault The vault address.
     * @param amount The amount redeemed.
     * @param shares The number of shares burned.
     */
    event Redeemed(
        address indexed vault,
        uint256 amount,
        uint256 shares
    );

    /**
     * @notice Emitted when a withdrawal claim is made.
     * @param vault The vault address.
     * @param period The period for which the claim is made.
     * @param amount The amount claimed.
     */
    event WithdrawalClaimed(
        address indexed vault,
        uint256 period,
        uint256 amount
    );

    /**
     * @notice Emitted when a redeem request is made.
     * @param vault The vault address.
     * @param shares The number of shares to redeem.
     * @param claimableEpoch The epoch when the claim becomes available.
     * @param year The year of the claimable date.
     * @param month The month of the claimable date.
     * @param day The day of the claimable date.
     */
    event RedeemRequested(
        address indexed vault,
        uint256 shares,
        uint256 claimableEpoch,
        uint256 year,
        uint256 month,
        uint256 day
    );

    /**
     * @notice Emitted when a claim is made for a specific date.
     * @param vault The vault address.
     * @param year The year of the claim.
     * @param month The month of the claim.
     * @param day The day of the claim.
     * @param shares The number of shares claimed.
     * @param amount The amount claimed.
     */
    event Claimed(
        address indexed vault,
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 shares,
        uint256 amount
    );

    /**
     * @notice Emitted when a signed batch of calls is sent to this account's remote twin on
     * the destination chain for execution.
     * @param operationId The user-chosen operation id.
     * @param callCount The number of calls in the batch.
     * @param destinationEid The destination chain's LayerZero endpoint id.
     * @param guid The LayerZero message id of the send.
     */
    event CrossChainUserOpSent(
        bytes32 operationId,
        uint256 callCount,
        uint32 destinationEid,
        bytes32 guid
    );

    /**
     * @notice Emitted when one of this account's subaccounts pushed FXRP here for redemption
     * and this account redeemed it to its XRPL owner.
     * @param subaccount The subaccount that pushed the FXRP.
     * @param amount Amount pulled from the subaccount and requested for redemption.
     * @param redeemedAmount Amount actually redeemed, which can be less - zero when the pushed
     * amount was below the FAssets minimum; the rest stays here, or went back to the subaccount
     * when it is itself redeemable ({FXrpReturnedToSubaccount}).
     * @param executor Executor used for the redemption.
     * @param valueForwarded Native value forwarded with the redemption (covers the executor
     * fee), or kept here when nothing was redeemed.
     */
    event FXrpRedeemedFromSubaccount(
        address indexed subaccount,
        uint256 amount,
        uint256 redeemedAmount,
        address executor,
        uint256 valueForwarded
    );

    /**
     * @notice Emitted when the part of a subaccount's pushed FXRP that FAssets did not fill went
     * back to the subaccount, being itself redeemable, so that its next sweep finishes it.
     * @param subaccount The subaccount that pushed the FXRP and received the remainder.
     * @param amount The remainder returned.
     */
    event FXrpReturnedToSubaccount(
        address indexed subaccount,
        uint256 amount
    );

    /**
     * @notice Reverts if the sent value is insufficient for collateral reservation.
     * @param collateralReservationFee The required collateral reservation fee.
     * @param executorFee The required executor fee.
     */
    error InsufficientFundsForCollateralReservation(
        uint256 collateralReservationFee,
        uint256 executorFee
    );

    /**
     * @notice Reverts if the sent value is insufficient for redeem operation.
     * @param executorFee The required executor fee.
     */
    error InsufficientFundsForRedeem(
        uint256 executorFee
    );

    /**
     * @notice Reverts if the caller is not the controller.
     */
    error OnlyController();

    /**
     * @notice Reverts if the agent is not available.
     */
    error AgentNotAvailable();

    /**
     * @notice Reverts if the token approval fails.
     */
    error ApprovalFailed();

    /**
     * @notice Reverts if a call in executeUserOp fails.
     * @param index The index of the call that failed.
     * @param returnData The return data from the failed call.
     */
    error CallFailed(uint256 index, bytes returnData);

    /**
     * @notice Reverts if {sendCrossChainUserOp} is called by anything other than this
     * account itself: it is reachable only through {executeUserOp}, so every instruction is
     * user-signed.
     */
    error OnlySelf();

    /**
     * @notice Reverts on a cross-chain user operation whose envelope cannot execute on the
     * remote account: a zero operation id, a deadline already passed, or an empty batch. Checked
     * here, before any bridge fee is paid; the batch itself is not interpreted.
     */
    error InvalidCrossChainUserOp();

    /**
     * @notice Reverts if {redeemFromSubaccount} is called by anything other than one of this
     * account's own subaccounts.
     */
    error OnlySubaccount();

    /**
     * @notice Reverts if a cross-chain user operation names a destination endpoint with no bridge
     * route on the controller (or the FXRP OFT adapter is not configured): the route registry is
     * the allowlist of chains this account may send to.
     * @param destinationEid The unregistered endpoint id.
     */
    error UnknownBridgeRoute(
        uint32 destinationEid
    );

    /**
     * @notice Reverts if the OFT's live peer for the destination chain no longer matches the pinned
     * one; the send fails closed instead of messaging an unknown remote OApp.
     */
    error WrongDestinationPeer();

    /**
     * @notice Reverts if the sent value does not cover the LayerZero messaging fee.
     * @param required The required fee.
     */
    error InsufficientFundsForInstruction(
        uint256 required
    );

    /**
     * @notice Sends a signed batch of calls to this account's remote twin (the remote Personal
     * Account at this same address on the chain `_destinationEid` names) for atomic execution
     * there - the remote `executeUserOp`, carried by the authenticated compose instead of the
     * controller.
     * @dev Callable only by this account itself, so it is reached through an {executeUserOp}
     * multicall and the XRPL signature covers every target, value and calldata end-to-end;
     * deliberately not reentrancy-guarded, since it runs inside that call's guard. The batch is
     * not interpreted here (the remote account runs it all or nothing, and a failed call leaves
     * the delivery retriable with the id unconsumed); only the envelope is validated before any
     * fee is paid (`InvalidCrossChainUserOp`: zero operation id, passed deadline, empty batch).
     * It validates the pause, the route (`UnknownBridgeRoute`: the destination must be a
     * registered bridge route - the registry is the allowlist of chains) and the pinned peer,
     * then sends a message-only compose to the same address: exactly the quoted fee is paid
     * from this account and any excess remains here. `_extraOptions` must carry the
     * `lzCompose` gas the batch needs and, when the batch sends more native than the remote
     * account holds, a native drop. The message id is recorded in {CrossChainUserOpSent}.
     * @param _destinationEid The LayerZero endpoint id of the remote chain; must be a
     * registered bridge route.
     * @param _calls The calls to execute from the remote account, in order.
     * @param _operationId The user-chosen operation id (non-zero, unique per account).
     * @param _deadline Unix time after which the remote account skips the instruction unexecuted.
     * @param _extraOptions Caller-supplied LayerZero execution options (type-3).
     */
    function sendCrossChainUserOp(
        uint32 _destinationEid,
        Call[] calldata _calls,
        bytes32 _operationId,
        uint64 _deadline,
        bytes calldata _extraOptions
    )
        external payable;

    /**
     * @notice Redeems FXRP pushed here by one of this account's subaccounts to this account's
     * XRPL owner: pulls exactly `_amount` from the calling subaccount and requests redemption of
     * exactly that - what FAssets fills of it is FAssets' to decide.
     * @dev Callable only by this account's own deterministic subaccounts (the controller's
     * prediction for this owner and the caller's type must be the caller). This account is the
     * recorded redeemer, so every outcome - a partial fill, a payment-default payout, a refund
     * - lands here, where {executeUserOp} handles anything, including triggering the default on
     * the asset manager directly; this account's own balance is never part of it. A pushed
     * amount below the FAssets minimum is kept here unredeemed, the value with it, and zero is
     * returned; an unfilled remainder of a partial fill goes back to the caller when it is
     * itself redeemable ({FXrpReturnedToSubaccount}) and stays here otherwise. The controller's
     * executor is appointed and all `msg.value` is forwarded as its fee (FAssets records it in
     * whole gwei); the caller rail, not this method, enforces the minimum fee.
     * Pause-exempt (an exit toward the user) and guarded in its own reentrancy domain, so the
     * signed {executeUserOp} -> sweepRedeem path works - a bounded nesting: the method writes no
     * account state and pulls before it redeems, so it can never touch this account's
     * pre-existing FXRP, and a nested redemption is refused.
     * @param _amount The amount pushed by the subaccount, pulled and redeemed here.
     * @return _redeemedAmount Amount actually redeemed, zero below the FAssets minimum; the
     * remainder stays here or went back to the caller.
     */
    function redeemFromSubaccount(
        uint256 _amount
    )
        external payable
        returns (uint256 _redeemedAmount);

    /**
     * @notice Execute a series of calls (user operation).
     * @param _calls Array of calls to execute.
     */
    function executeUserOp(
        Call[] calldata _calls
    )
        external payable;
}
