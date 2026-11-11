// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IBridgingSubaccount} from "./IBridgingSubaccount.sol";
import {IRedeemingSubaccount} from "./IRedeemingSubaccount.sol";

/*
 * The wire schema of a loan subaccount pair: the actions a compose payload can carry and the
 * destination kinds a borrow can disburse to. Both halves of a pair speak it - the Flare half
 * encodes it, the loan-chain half executes it - so it belongs to neither venue. What an action
 * then does to a position is the executing half's own; for the Morpho pair that is written out
 * in {IMorphoLoanSubaccountRemote}.
 */

/// @dev Borrow action: `actionData` is `abi.encode(bytes32 operationId, uint64 deadline,
/// uint8 destinationKind, bytes32 destination, uint256 borrowAmount, uint256 minComposeValue)`.
/// The floor is reserved for a destination kind that pays for its own onward delivery;
/// `DESTINATION_KIND_EVM` must leave it zero ({UnexpectedDeliveryValueFloor}). The market is not a
/// payload field: the account type fixes it (write-once), so the subaccount address itself
/// commits to the pool. The bridged collateral and any residue on the account are supplied, and
/// `borrowAmount` (non-zero) is borrowed and sent to `destination`; a zero bridged amount with
/// nothing idle borrows against the existing position. The operation id
/// must be non-zero and globally unique per subaccount across the actions that carry one (the
/// borrow and the withdraw); clients
/// retrying an expired intent must reuse its id only for the same intent with a fresh
/// deadline (a convention, not contract-enforced). A pure collateral deposit is its own action
/// (`ACTION_DEPOSIT_COLLATERAL`).
uint8 constant ACTION_BORROW = 1;

/// @dev Withdraw action: `actionData` is `abi.encode(bytes32 operationId, uint64 deadline,
/// uint256 withdrawAmount, uint256 minAmount, uint256 minComposeValue,
/// bytes returnOptions)`. The atomic
/// withdrawal: withdraws collateral from the account's one position and bridges it back to the
/// account's own Flare address in the same execution, with the redeem-home compose - no idle
/// window, so the redeposit ordering race cannot touch a withdrawal. `minAmount` is the
/// signed floor on what must arrive home (non-zero, at most `withdrawAmount`): the FXRP OFT
/// adapters are fee-capable and this leg is quoted only on delivery - after the instruction was
/// signed - so the allowance travels in the payload rather than being read there, and a cut
/// above it reverts the delivery (`SlippageExceeded`, retriable) instead of coming out of the
/// user's collateral. The loan chain re-validates it (`InvalidMinAmountReceived`) before any
/// branch that finalizes the packet. `minComposeValue` is the
/// delivery floor:
/// compose delivery is permissionless and LayerZero does not authenticate the delivered value,
/// so a delivery carrying less - execution and terminal skip alike - reverts
/// (`InsufficientDeliveryValue`), which is what stops a zero-value front-run from consuming
/// the packet and burning the prepaid value. `returnOptions` are the signed return-send
/// options (Flare-side gas and, as compose value, the redemption's executor fee - at least
/// the Flare controller's configured fee, which the redeem-home charges exactly as the public
/// sweep does; a delivery bringing less parks, retriable, until one brings it or anyone
/// sweeps); the return
/// fee is paid from the compose value delivered with this action - the only action that
/// accepts value - and the excess goes to the parent. Every failure reverts and leaves the
/// delivery retriable; what recovers it differs by cause, and for the Morpho pair
/// {IMorphoLoanSubaccountRemote} writes each cause out.
uint8 constant ACTION_WITHDRAW = 2;

/// @dev Deposit-collateral action: carries no action data (empty bytes) - no operation id, since
/// a re-issued deposit (a new packet; a delivered compose cannot replay) only adds the user's own
/// collateral, which the permissionless rail can do
/// with the same tokens anyway, and no deadline, since a late deposit is harmless. It supplies
/// the account's idle collateral and moves no debt.
uint8 constant ACTION_DEPOSIT_COLLATERAL = 3;

/// @dev Redeem-home action, the one the Flare half receives: the compose the loan-chain twin's
/// bridge-back attaches to the FXRP it returns - the withdraw action's return leg.
/// Its `actionData` is empty: the packet is an instruction to redeem, not a number, and the
/// Flare account redeems whatever it holds on arrival - the packet's credit and any idle
/// balance beside it - exactly as {IRedeemingSubaccount.sweepRedeem} would, and at the same
/// price: the compose value is the executor fee and must reach the controller's configured one
/// ({IRedeemingSubaccount.InsufficientFundsForRedeem}), so a delivery bringing less reverts and
/// stays retriable, for a `lzCompose` retry carrying the current fee or for anyone's sweep -
/// which is what the operator can for a packet a fee change caught in flight. No deadline: a
/// late packet finds the balance a sweep would find and does with it only what anyone may do.
uint8 constant ACTION_REDEEM_HOME = 4;

/// @dev Cancel action: `actionData` is `abi.encode(bytes32 operationId)`. Message-only, and the
/// one action that withdraws an authority instead of using one: it consumes the id so the packet
/// that carried it can never execute, and does nothing else. It carries no deadline of its own (a
/// late cancellation is either
/// unnecessary or still correct). Sending one is NOT cancellation: the two packets race, and an
/// original that arrives first executes normally, after which the cancellation finds the id
/// consumed and finalizes quietly without an event - so a client resolves a sent cancellation
/// by whichever arrives, {LoanActionCancelled} or the original action's own execution event,
/// and either ends the instruction's live state. Cancelling an id that was never issued is
/// allowed and simply burns it, which is what makes the action idempotent and its delivery
/// terminal on the first attempt.
uint8 constant ACTION_CANCEL = 5;

/// @dev The destination is an EVM address (cleanly zero-padded into the `bytes32`), paid by a
/// plain ERC-20 transfer — typically an exchange deposit address, or the user's own
/// loan-chain Personal Account (the parent, a functional compose-driven account). It may not
/// be zero or the subaccount itself (the proceeds could only repay the new debt).
uint8 constant DESTINATION_KIND_EVM = 1;

/// @dev Reserved: an XRPL address reached over Wormhole. Not implemented yet (Wormhole specs
/// pending); payloads using it revert.
uint8 constant DESTINATION_KIND_XRPL_WORMHOLE = 2;

/**
 * @title ILoanSubaccount
 * @notice User interface for deterministic loan subaccounts on Flare: the parent-driven loan
 * instructions, typed payload encoders over the shared forward move. The permissionless rail
 * (`sweepRedeem`) is the redeeming surface every type whose idle FXRP means home shares, declared
 * on {IRedeemingSubaccount}; the compose ingress of the loan-chain twin's messages is the bridging
 * surface, declared on {IBridgingSubaccount}; the redeem-home action those messages carry
 * ({ACTION_REDEEM_HOME}) is this type's own, dispatched into the same redemption as the rail.
 */
interface ILoanSubaccount is IBridgingSubaccount, IRedeemingSubaccount {

    /// @notice The signed LayerZero options and delivery-value floor of the two-leg withdrawal.
    /// The operator quotes the return leg first, against `returnOptions` - so that quote already
    /// contains the redemption's executor fee those options buy - puts it (plus headroom; the
    /// excess lands on the parent) into `destinationOptions` as compose value, then quotes and
    /// sends the first message. One payment, made on Flare, covers both legs and the
    /// redemption.
    struct WithdrawOptions {
        /// @notice Flare -> loan chain: the withdraw compose's gas and, as compose value, the
        /// native that pays for the whole way back - the return leg's LayerZero fee, which
        /// itself buys the native the Flare compose arrives with, the redemption's executor
        /// fee. Nothing is paid on the loan chain out of the user's own funds.
        bytes destinationOptions;
        /// @notice Loan chain -> Flare: the redeem-home compose's gas and, as compose value,
        /// the redemption's executor fee - at least the Flare controller's configured fee, the
        /// price the public sweep pays too; a delivery bringing less parks the redemption
        /// (retriable) until a `lzCompose` retry brings the current fee or anyone sweeps - the
        /// operator can do either, when a fee change caught a packet in
        /// flight. The fee is read when the packet arrives, and a change to it is timelocked -
        /// known in advance, so a return leg signed before one can be sized for it. Signed
        /// end-to-end
        /// and frozen into the instruction - a bad blob parks the withdrawal until a fresh
        /// instruction (reuse the same operation id, so the parked packet terminal-skips as a
        /// duplicate).
        bytes returnOptions;
        /// @notice The delivery-value floor (non-zero): compose delivery is permissionless and
        /// LayerZero does not authenticate the delivered value, so the loan chain refuses any
        /// delivery of this withdraw - execution and terminal skip alike - carrying less than
        /// this. Set it to the compose value bought in `destinationOptions`, so a front-run
        /// with less cannot consume the packet and burn the prepaid value - and never above
        /// it: the floor is checked before the expiry skip, so a packet whose bought value is
        /// below its own floor reverts on every delivery, even after its deadline, and never
        /// finalizes (no funds at risk - the value was never delivered, and a reissue on the
        /// same operation id executes normally - but the orphan stays queued at the endpoint).
        uint256 minComposeValue;
    }

    /**
     * @notice Emitted when a borrow instruction is sent to this account's loan-chain twin.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The user-chosen operation id.
     * @param collateralAmount FXRP bridged with the instruction, to become collateral.
     * @param borrowAmount Loan-token amount to borrow and disburse (non-zero).
     * @param destinationKind The disbursement destination kind.
     * @param destination The disbursement destination.
     * @param destinationEid The loan chain's LayerZero endpoint id.
     * @param guid The LayerZero message id.
     */
    event BorrowInstructionSent(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        uint256 collateralAmount,
        uint256 borrowAmount,
        uint8 destinationKind,
        bytes32 destination,
        uint32 destinationEid,
        bytes32 guid
    );

    /**
     * @notice Emitted when a deposit-collateral instruction is sent to this account's
     * loan-chain twin.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param amount FXRP bridged with the instruction, to become collateral.
     * @param destinationEid The loan chain's LayerZero endpoint id.
     * @param guid The LayerZero message id.
     */
    event CollateralDepositInstructionSent(
        address indexed parentPersonalAccount,
        uint256 amount,
        uint32 destinationEid,
        bytes32 guid
    );

    /**
     * @notice Emitted when a cancellation is sent to this account's loan-chain twin. Sending it
     * is not cancellation: the two packets race, and the loan chain's {LoanActionCancelled} is
     * what says the id was actually consumed.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The operation id the cancellation names.
     * @param destinationEid The LayerZero endpoint id of the loan chain.
     * @param guid The LayerZero message id of the cancellation.
     */
    event LoanCancelInstructionSent(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        uint32 destinationEid,
        bytes32 guid
    );

    /**
     * @notice Emitted when a withdraw instruction is sent to this account's loan-chain twin.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The user-chosen operation id.
     * @param amount Collateral to withdraw on the loan chain.
     * @param destinationEid The loan chain's LayerZero endpoint id.
     * @param guid The LayerZero message id.
     */
    event WithdrawInstructionSent(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        uint256 amount,
        uint32 destinationEid,
        bytes32 guid
    );

    /**
     * @notice Reverts on a loan instruction whose arguments cannot execute on the loan chain:
     * a zero operation id or a deadline already passed (borrow and withdraw), a zero borrow,
     * deposit or withdrawal amount, a borrow disbursement that is not a clean non-zero EVM address other than
     * this account, a borrow naming a delivery-value floor for a destination kind that cannot
     * spend value, or a withdraw with a zero delivery-value floor. Checked here, before any
     * bridge fee is paid.
     */
    error InvalidLoanInstruction();

    /**
     * @notice The borrow instruction: bridges `_collateralAmount` FXRP (zero for a borrow
     * against existing collateral) with the typed payload that supplies it as collateral,
     * borrows `_borrowAmount` on the loan-chain twin's market and disburses it. A pure
     * collateral deposit is its own instruction, {depositCollateral}.
     * @dev Restricted to the parent Personal Account: the instruction names a loan action and
     * a user-chosen disbursement destination, so it must carry the user's XRPL signature. The
     * payload is built here, not passed in, so a malformed payload cannot reach the bridge; the
     * envelope and the EVM destination are validated before quoting
     * ({InvalidLoanInstruction}) and the loan chain re-validates on delivery. It sends to this
     * account's own cross-chain address through the configured pinned peer, sharing the
     * bridging core's guards: paused reverts, a configured route that is not suspended required,
     * live peer re-checked. `_extraOptions` must be type-3 options carrying both the destination
     * `lzReceive` gas and the `lzCompose` gas. `msg.value` must cover the LayerZero fee; the
     * excess is refunded to the parent. On the loan chain the borrow is also refused, retriably,
     * when the post-borrow position would fall under the cover gate
     * (`InsufficientRemainingCollateral`) - the same rule that gates {withdraw}: the collateral
     * must be worth `1.155 / LLTV` of the debt plus twice the collectible Flare fee.
     * @param _minCollateralAmount The least FXRP that must arrive on the loan chain; zero
     * when `_collateralAmount` is zero, otherwise non-zero and at most that amount. The
     * adapter is fee-capable, so this is the user's signed allowance for its cut - set it to
     * `_collateralAmount` when no fee is expected.
     * @param _collateralAmount FXRP to bridge and supply as collateral; may be zero, at most
     * the account's balance.
     * @param _borrowAmount Loan-token amount to borrow and disburse; non-zero.
     * @param _destinationKind The disbursement destination kind (`DESTINATION_KIND_*`).
     * @param _destination The disbursement destination (a clean zero-padded EVM address for
     * `DESTINATION_KIND_EVM`).
     * @param _minComposeValue The delivery-value floor for a destination kind that spends
     * compose value on the loan chain, in the loan chain's native token. Reserved: every kind V1
     * supports disburses without spending value, so `DESTINATION_KIND_EVM` requires zero and a
     * non-zero floor is refused here, before any bridge fee. It exists in the frozen V1 payload
     * to reduce what enabling a kind that does pay for its own onward delivery has to move -
     * implementations and governed parameters rather than the wire schema. It does not
     * guarantee that: a floor protects delivery funding and settles nothing about quote
     * validity, a spending cap, or an XRPL destination tag, so a kind needing any of those
     * still arrives as a new payload version. Its meaning, once such a kind
     * exists, is the withdraw's: the loan chain refuses any delivery of this borrow - execution
     * and terminal skip alike - carrying less than this, so a front-run with less cannot consume
     * the packet and burn the prepaid value.
     * @param _operationId The user-chosen operation id (non-zero, unique per subaccount).
     * @param _deadline Unix time after which the loan chain skips the instruction unexecuted.
     * Keep it short (under an hour): the loan is priced at the type's fee terms current at
     * delivery, so the front end warns while a terms change is pending in the timelock, and a
     * short deadline is what bounds how far past that warning a delayed packet can execute.
     * @param _extraOptions Caller-supplied LayerZero execution options (type-3).
     */
    function borrow(
        uint256 _collateralAmount,
        uint256 _minCollateralAmount,
        uint256 _borrowAmount,
        uint8 _destinationKind,
        bytes32 _destination,
        uint256 _minComposeValue,
        bytes32 _operationId,
        uint64 _deadline,
        bytes calldata _extraOptions
    )
        external payable;

    /**
     * @notice The deposit-collateral instruction: bridges exactly `_amount` FXRP to this
     * account's own address on the loan chain, with the typed deposit payload the loan-chain
     * twin executes on arrival — supply the bridged amount as collateral, no debt change.
     * @dev Restricted to the parent Personal Account; same guards and fee handling as
     * {borrow}. It carries no operation id and no deadline: a deposit only adds the user's own
     * collateral, which the loan chain's permissionless rail can do with the same tokens
     * anyway, so neither replay protection nor expiry buys anything (the loan-chain action is
     * id-less, like the Flare redeem-home). On the loan chain the deposit is the defensive
     * move: while the controller is paused it still executes when the position carries live
     * debt.
     * @param _amount FXRP to bridge and supply as collateral; non-zero, at most the balance.
     * @param _minAmount The least FXRP that must arrive on the loan chain; non-zero and
     * at most `_amount` - the user's signed allowance for the adapter's fee.
     * @param _extraOptions Caller-supplied LayerZero execution options (type-3).
     */
    function depositCollateral(
        uint256 _amount,
        uint256 _minAmount,
        bytes calldata _extraOptions
    )
        external payable;

    /**
     * @notice The withdraw instruction: a typed, message-only send that atomically withdraws
     * `_amount` of collateral on the loan chain and bridges it home for redemption — no idle
     * window there, so nothing can be redeposited from under it.
     * @dev Restricted to the parent Personal Account; same validation, guards, and fee
     * handling as {borrow}. No FXRP travels with it, but `_options.destinationOptions` must
     * carry, as compose value, the native that prepays the return leg's LayerZero fee (quoted
     * against `_options.returnOptions` on the loan chain, so it includes the redemption's
     * executor fee those options buy; the excess lands on the parent, and too little parks the
     * delivery as retriable). See {WithdrawOptions} for the signed
     * delivery-value floor. A withdrawal that would leave the position under the loan chain's
     * exit gate reverts there (`InsufficientRemainingCollateral`, retriable) until debt and
     * fee are repaid in loan tokens through the subaccount's `repay`, or a smaller amount is
     * signed.
     * @param _amount Collateral to withdraw on the loan chain and bridge home; non-zero.
     * @param _minAmount The least FXRP that must arrive home on the return leg (non-zero, at
     * most `_amount`). The FXRP OFT is fee-capable, and the loan chain quotes the bridge home
     * only when this instruction is delivered - after it was signed - so the floor is named
     * here and carried, never quoted there: a fee raised in between is refused rather than
     * taken out of the user's collateral. Set it to `_amount` when no fee is expected; a fee
     * above the allowance parks the withdrawal (retriable) until a fresh instruction allows it.
     * @param _operationId The user-chosen operation id (non-zero, unique per subaccount).
     * @param _deadline Unix time after which the loan chain skips the instruction unexecuted.
     * @param _options The two option blobs and the delivery-value floor ({WithdrawOptions});
     * `minComposeValue` must be non-zero.
     */
    function withdraw(
        uint256 _amount,
        uint256 _minAmount,
        bytes32 _operationId,
        uint64 _deadline,
        WithdrawOptions calldata _options
    )
        external payable;

    /**
     * @notice The cancel instruction: a message-only send that consumes `_operationId` on the
     * loan chain, so a borrow or withdraw packet carrying that id can never execute.
     * @dev Restricted to the parent Personal Account. The motivating case is a borrow parked by
     * a failed health check after a price drop, which any collateral landing - the user's own
     * deposit or the permissionless rail - would otherwise make executable again. Sending this
     * is not cancellation: the two packets race, an original that lands first executes
     * normally and the cancellation then finalizes silently - so a client resolves a sent
     * cancellation by whichever arrives, the loan chain's
     * {IMorphoLoanSubaccountRemote.LoanActionCancelled} or the original action's own execution event,
     * either of which ends the instruction's live state; and an id a cancellation was signed
     * for is retired for good. It carries no deadline (a late
     * cancellation is unnecessary or still correct). On the loan chain it is not pause-gated;
     * here it travels the ordinary instruction path, which a Flare pause closes like every
     * other instruction (the controller's instruction facets and the bridge send both check
     * it), so a parked packet cannot be revoked from a paused Flare. In that state the loan
     * chain's own pause suspends the borrow but cancels nothing, so the order is: pause the loan
     * chain, restore Flare when safe, submit and confirm the cancellation while the loan chain
     * stays paused, then resume - unpausing it earlier makes the latent packet executable again.
     * Burning an unissued id is allowed and makes a re-send harmless.
     * @param _operationId The operation id to consume; must be non-zero.
     * @param _extraOptions LayerZero options for the cancel message (gas only - it moves no
     * tokens and needs no compose value).
     */
    function cancel(
        bytes32 _operationId,
        bytes calldata _extraOptions
    )
        external payable;

}
