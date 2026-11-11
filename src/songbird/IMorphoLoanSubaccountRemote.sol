// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IComposeReceiverAccountBase} from "./IComposeReceiverAccountBase.sol";
import {ISubaccount} from "./ISubaccount.sol";

/*
 * What each action of the wire schema ({ILoanSubaccount}, where the payload layouts are) does on
 * this market.
 *
 * `ACTION_BORROW`. The account's whole idle FXRP balance - the authenticated bridged amount (the
 * codec's `amountLD`) plus any residue - becomes collateral, and the borrowed loan tokens go to
 * the payload's destination. The fee terms are the type's current terms at delivery (the front
 * end warns while a change is pending in the timelock and keeps deadlines short; see the spec).
 * It is a debt increase: pause-gated and subject to the per-type borrow switch, both of which
 * revert retriably. **The cover gate** applies to the post-borrow position: its collateral (the
 * supplied credit included), at the market oracle's price, must cover `1.155 / LLTV` of the new
 * debt plus twice the collectible fee - the same rule as the withdraw's, Morpho's own liquidation
 * line with a headroom, so it implies Morpho's health check - or the delivery reverts retriably
 * (`InsufficientRemainingCollateral`) with nothing supplied or disbursed. Morpho's check runs
 * first, inside its borrow, so a borrow past Morpho's own line (or under a dead oracle) fails
 * there with Morpho's error instead; and unlike the withdraw, a borrow has no oracle-free route -
 * it needs the oracle back.
 *
 * `ACTION_WITHDRAW`. **The exit gate**: the withdrawal passes while the collateral remaining
 * after it, valued at the market oracle's price, covers `1.155 / LLTV` of the live debt plus
 * twice the collectible fee (1.5x at the launch market's 77% LLTV - Morpho's own liquidation line
 * with a headroom, so the gate implies Morpho's health check), and otherwise reverts retriably
 * (`InsufficientRemainingCollateral`, carrying the required cover and the remaining value) - debt
 * and fee are paid in loan tokens through {repay}, never taken from the collateral, so no price
 * ever moves funds here. Every failure leaves the delivery retriable, and this is the one place
 * what recovers it is written out. A quote shortfall: retry the SAME packet with more value.
 * Another transient return-send failure: retry the same packet once its cause clears - more value
 * cannot help, since exactly the newly quoted fee is forwarded. An uncovered remainder
 * (`InsufficientRemainingCollateral`, which a dead or zero-priced oracle also produces, since
 * it values the remainder at nothing): repay - send loan tokens to the account and let {repay}
 * split them pro rata between debt and fee (every payment shrinks the required cover; covering
 * both settles the position once the fee has actually been collected - a fee the collector
 * cannot receive stays owed and reserved, and a later {repay} retries it) - after which the
 * retried delivery passes, oracle-free once nothing is owed; or sign a smaller withdrawal. Bad
 * `returnOptions` frozen into the signed packet (the accepted residual - no retry can fix the
 * blob itself): issue a corrected instruction reusing the SAME operation id, whereupon the parked
 * packet later duplicate-skips. Position health is enforced by Morpho.
 *
 * `ACTION_DEPOSIT_COLLATERAL`. Supplies the account's whole idle FXRP balance as collateral on
 * its one market: the authenticated bridged amount (the codec's `amountLD`, which must be
 * non-zero) plus any residue waiting for the permissionless rail, less whatever that rail already
 * put into the position before delivery; no debt changes hands. While the controller is paused it
 * executes only when the position carries live debt (the defensive case - protecting an
 * endangered position); a debt-free deposit is new exposure and waits out the pause. With a
 * principal it checkpoints the fee first, as {depositIdleFxrp} does.
 *
 * `ACTION_CANCEL`. Consumes the id and nothing more: no market read, no fee terms, no borrow
 * switch, no collateral or debt moves. It is not pause-gated, since revoking an authority is not
 * new exposure.
 */

/**
 * @title IMorphoLoanSubaccountRemote
 * @notice User interface for the loan-chain-side subaccount (Ethereum, at launch), at the same
 * CREATE2 address as its Flare counterpart. Authenticated compose payloads, sent by this same
 * account on Flare, execute the typed actions on the type's write-once Morpho market — so the
 * address itself commits to the pool. Repayment, idle-collateral deposit and the fee
 * checkpoint are permissionless fixed rails, and nothing here is parent-callable. Idle FXRP
 * has one route, into the position ({depositIdleFxrp}), from where
 * the signed withdraw action brings it home under the position's ordinary conditions. Across
 * the rails and the signed actions every destination is fixed on-chain - the account's own
 * position, the parent, the governance-set fee recipient, or (the withdraw's return leg) this
 * account's own address on Flare - while the one user-chosen destination is a signed
 * borrow's disbursement. It has no native rail.
 */
interface IMorphoLoanSubaccountRemote is IComposeReceiverAccountBase, ISubaccount {

    /**
     * @notice The position as the front end needs it, projected to the current block: Morpho's
     * debt brought forward the way its accrual will bring it (the market's rate model over the
     * time since the market's last update), the fee's current period priced at the snapshotted
     * terms. Every field is a quote for the observed block - the contract recomputes at delivery.
     * @param collateral Collateral in the Morpho position, in collateral-token base units.
     * @param idleCollateral Collateral on the account, not in the position: the deposit rail, the
     * deposit action or the next borrow supplies it; a withdrawal leaves it where it is, so it is
     * not withdrawable position collateral.
     * @param idleLoanToken Loan tokens on the account: repay fuel, a reserved fee or a retained
     * surplus, all of which the next {repay} consumes.
     * @param debt The live Morpho debt, interest to this block included.
     * @param feeDebtX18 The fee payable now - the running period projected to this block - at
     * WAD precision (base units x 1e18); the whole units, `feeDebtX18 / 1e18`, are the
     * collectible.
     * @param oraclePrice The market oracle's price (1e36 scale); zero when the oracle is dead
     * or answers zero - the gate then values the collateral at nothing.
     * @param collateralValue `collateral` at that price, in loan tokens.
     * @param lltv The market's liquidation LTV (WAD).
     * @param requiredCover The cover gate's demand on the position as it stands, in loan tokens.
     * @param morphoHealthFactor Morpho's distance to liquidation, `collateralValue x lltv / debt`
     * (WAD): above 1e18 healthy, 1e18 on Morpho's line; the maximum value when debt-free; zero
     * when the oracle is dead with live debt. Flare's cover is the stricter line - compare
     * `collateralValue` with `requiredCover` for that one.
     * @param liquidationPrice The lowest oracle price (1e36 scale) at which Morpho still holds
     * the position healthy, both of its floor steps included: one unit below it the position is
     * liquidatable. Zero when debt-free (never liquidatable), the maximum value when there is
     * debt and no collateral (liquidatable at any price).
     */
    struct LoanPosition {
        uint256 collateral;
        uint256 idleCollateral;
        uint256 idleLoanToken;
        uint256 debt;
        uint256 feeDebtX18;
        uint256 oraclePrice;
        uint256 collateralValue;
        uint256 lltv;
        uint256 requiredCover;
        uint256 morphoHealthFactor;
        uint256 liquidationPrice;
    }

    /**
     * @notice What the cover gate and the market allow next, projected to the current block.
     * @param maxBorrowByCover The largest further borrow the cover gate passes once the idle
     * collateral and `additionalCollateral` are supplied with it (Morpho's own rounding
     * included); zero under a dead oracle. The cover check only: the pool's liquidity
     * (`marketLiquidity`), the pause, the borrow switch and the transport are separate
     * conditions.
     * @param marketLiquidity The loan tokens the pool can still lend: its supply total minus its
     * borrow total, both brought to this block. Morpho refuses a borrow above it.
     * @param maxWithdraw The largest withdrawal the cover gate passes on the position as it
     * stands: the whole collateral when nothing is owed, zero under a dead oracle otherwise. The
     * cover check only; the pause and the transport are separate conditions.
     */
    struct LoanLimits {
        uint256 maxBorrowByCover;
        uint256 marketLiquidity;
        uint256 maxWithdraw;
    }

    /**
     * @notice What a {repay} would do now with the loan tokens already on the account plus a
     * top-up - the EXPECTED allocation: a fee transfer the collector's token refuses is deferred
     * or reserved at execution instead, so the fee then stays owed and the debt takes its share.
     * Oracle-free, like {repay} itself. The payment allocated is the loan tokens on the account
     * plus the top-up.
     * @param feePaid The fee collected: the pro-rata share of a payment short of debt plus fee,
     * the whole collectible otherwise.
     * @param debtPaid The Morpho repayment.
     * @param surplus Pushed to the parent - only once the debt is closed; anything else that is
     * left stays on the account (a reserved fee, or the remainder of a partial payment).
     * @param debtAfter The Morpho debt afterwards, Morpho's rounding included.
     * @param collectibleAfter The fee still payable afterwards.
     * @param closingTopUp The top-up that closes both claims now: debt plus collectible, less
     * what is already on the account.
     */
    struct RepayPreview {
        uint256 feePaid;
        uint256 debtPaid;
        uint256 surplus;
        uint256 debtAfter;
        uint256 collectibleAfter;
        uint256 closingTopUp;
    }

    /**
     * @notice Whether a withdrawal of a given amount passes the cover gate now, and what
     * reopens it if not. The cover check only: an amount above the collateral, the pause and the
     * transport are Morpho's and the delivery's own refusals.
     * @param coverSatisfied True when the cover check passes the withdrawal on the position as
     * it stands - the check, not a promise of execution.
     * @param requiredCover The cover the gate demands, in loan tokens.
     * @param remainingValue The collateral left after the withdrawal at the oracle's price;
     * zero under a dead oracle.
     * @param minimumTopUp The smallest loan-token top-up whose {repay}, together with the loan
     * tokens already on the account, makes the withdrawal pass - the expected allocation, see
     * {previewRepay}; zero when it already passes. Closing both claims always suffices.
     */
    struct WithdrawPreview {
        bool coverSatisfied;
        uint256 requiredCover;
        uint256 remainingValue;
        uint256 minimumTopUp;
    }

    /**
     * @notice Whether a borrow of a given amount, with the idle collateral and a packet's
     * collateral supplied first, passes the cover gate now - the cover check only; the pool's
     * liquidity is reported beside it, the pause, the borrow switch and the transport are
     * separate conditions, and the amount is not otherwise validated.
     * @param coverSatisfied True when the post-borrow position passes the cover check.
     * @param requiredCover The cover the gate demands of the post-borrow position, in loan
     * tokens.
     * @param collateralValue The supplied collateral - in the position, idle and the packet's -
     * at the oracle's price; zero under a dead oracle.
     * @param debtAfter The Morpho debt after the borrow, its share rounding included.
     * @param marketLiquidity The loan tokens the pool can still lend; Morpho refuses a borrow
     * above it.
     */
    struct BorrowPreview {
        bool coverSatisfied;
        uint256 requiredCover;
        uint256 collateralValue;
        uint256 debtAfter;
        uint256 marketLiquidity;
    }

    /**
     * @notice Emitted when a borrow action executes.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The user-chosen operation id, now consumed.
     * @param collateralSupplied FXRP supplied in this execution: the whole idle balance - the
     * bridged credit plus any residue, less whatever the permissionless deposit rail had already
     * put into the position (zero for a message-only borrow with nothing idle).
     * @param borrowAmount Loan-token amount borrowed and disbursed (non-zero).
     * @param destinationKind The destination kind (see the `DESTINATION_KIND_*` constants).
     * @param destination The disbursement destination.
     * @param guid The LayerZero message id the action arrived with.
     */
    event LoanOpened(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        uint256 collateralSupplied,
        uint256 borrowAmount,
        uint8 destinationKind,
        bytes32 destination,
        bytes32 guid
    );

    /**
     * @notice Emitted when a deposit-collateral action executes.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param amount FXRP supplied in this execution: the whole idle balance - the bridged credit
     * plus any residue, less whatever the permissionless deposit rail had already put into the
     * position.
     * @param guid The LayerZero message id the action arrived with.
     */
    event CollateralDeposited(
        address indexed parentPersonalAccount,
        uint256 amount,
        bytes32 guid
    );

    /**
     * @notice Emitted when a withdraw action executes; the withdrawn collateral is bridged
     * home in the same execution ({FXrpBridgedToOrigin} follows).
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The user-chosen operation id, now consumed.
     * @param amount Collateral withdrawn from the position and bridged.
     * @param guid The LayerZero message id the action arrived with.
     */
    event CollateralWithdrawn(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        uint256 amount,
        bytes32 guid
    );

    /**
     * @notice Emitted when a cancel action consumes an operation id, so the borrow or withdraw
     * packet carrying that id can no longer execute. Absent when the id was already consumed -
     * the original won the race, or the cancellation was delivered twice.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The operation id now consumed.
     * @param guid The LayerZero message id the cancellation arrived with.
     */
    event LoanActionCancelled(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        bytes32 guid
    );

    /**
     * @notice Emitted when idle loan tokens are repaid into the account's position.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param assets The assets repaid (clamped to the live debt).
     */
    event LoanRepaid(
        address indexed parentPersonalAccount,
        uint256 assets
    );

    /**
     * @notice Emitted when idle FXRP is deposited as collateral into the account's position.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param amount The amount deposited.
     */
    event IdleFxrpDeposited(
        address indexed parentPersonalAccount,
        uint256 amount
    );

    /**
     * @notice Emitted when FXRP is bridged back to this account's address on the origin
     * chain, to be redeemed on arrival: a withdraw action's return leg.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param amount The amount bridged.
     * @param originEid The origin chain's LayerZero endpoint id.
     * @param guid The LayerZero message id of the bridge-back send.
     */
    event FXrpBridgedToOrigin(
        address indexed parentPersonalAccount,
        uint256 amount,
        uint32 originEid,
        bytes32 guid
    );

    /**
     * @notice Emitted when native value is forwarded to the parent Personal Account
     * (the remote implementation): the excess of a withdraw action's return-leg fee, or the whole value of a
     * terminally skipped withdraw delivery - it must not strand on an account with no
     * native rail.
     * @param parentPersonalAccount The parent Personal Account address paid.
     * @param amount The native value forwarded.
     */
    event NativeSweptToParent(
        address indexed parentPersonalAccount,
        uint256 amount
    );

    /**
     * @notice Emitted after each fee checkpoint and re-baseline, degenerate ones included
     * (zero principal or a zero elapsed period skip the fee math but still re-baseline).
     * @param parentPersonalAccount The parent Personal Account address.
     * @param principal The canonical Morpho debt measured at the checkpoint (base units); a
     * borrow or repayment in the same call re-syncs it afterward
     * ({LoanFeePrincipalSynced}), and {getLoanFeeState} is authoritative.
     * @param feeDeltaX18 The fee accrued for the interval (base units at WAD precision); zero
     * on degenerate checkpoints.
     */
    event LoanFeeCheckpointed(
        address indexed parentPersonalAccount,
        uint256 principal,
        uint256 feeDeltaX18
    );

    /**
     * @notice Emitted when a borrow or repayment re-syncs the fee base to the canonical
     * post-action debt (the clock and terms snapshot stay).
     * @param parentPersonalAccount The parent Personal Account address.
     * @param principal The canonical Morpho debt after the action (base units) - the base
     * the next period is priced on.
     */
    event LoanFeePrincipalSynced(
        address indexed parentPersonalAccount,
        uint256 principal
    );

    /**
     * @notice Emitted when accrued fee is paid to the fee recipient in loan tokens: from the
     * account's balance in {repay} (the fee's pro-rata share of a partial payment, or, once
     * the debt is closed, as much of the collectible as the balance covers).
     * @param feeRecipient The collector paid.
     * @param amount The amount paid (whole base units; the fee debt shrinks by exactly this).
     */
    event LoanFeeCollected(
        address indexed feeRecipient,
        uint256 amount
    );

    /**
     * @notice Emitted when a sub-unit fee remainder is forgiven at an exit gate: on a
     * debt-free position it can never be
     * transferred (ERC-20 moves whole base units) and never grows again, so a raw-zero gate
     * would park the exit forever over less than one base unit. Never more than a sub-unit
     * remainder: a whole base unit or more stays owed.
     * @param remainderX18 The forgiven remainder (base units at WAD precision, below 1e18).
     */
    event LoanFeeRemainderForgiven(
        uint256 remainderX18
    );

    /**
     * @notice Emitted with the amount of outstanding fee covered by loan tokens retained on
     * the account instead of leaving as surplus; a later {repay} retries from it. A snapshot,
     * not a delta: repeated calls can emit the same amount, and a collection that empties the
     * balance reserves zero (the claim then lives only in the fee debt).
     * @param feeRecipient The collector the reservation is owed to.
     * @param amount The reserved amount (whole base units).
     */
    event LoanFeeReserved(
        address indexed feeRecipient,
        uint256 amount
    );

    /**
     * @notice Emitted when the initial pro-rata attempt of a partial {repay} failed to pay
     * the fee's share - the token refused the recipient (RLUSD can freeze addresses). The share
     * stays in the repayment balance and repays debt; if that closes the debt, the remainder
     * is attempted again and whatever still cannot be paid is reserved on the account
     * ({LoanFeeReserved}). Whatever the call leaves unpaid stays owed; a later {repay}
     * collects it.
     * @param feeRecipient The collector the share was owed to.
     * @param amount The unpaid share (whole base units).
     */
    event LoanFeeDeferred(
        address indexed feeRecipient,
        uint256 amount
    );

    /**
     * @notice Emitted when a closed position's loan-token surplus is sent to the parent
     * Personal Account (the user's own account on this chain) at the end of {repay}.
     * @param parentPersonalAccount The parent Personal Account address paid.
     * @param amount The surplus amount.
     */
    event LoanSurplusRecovered(
        address indexed parentPersonalAccount,
        uint256 amount
    );

    /**
     * @notice Emitted when a closed position's loan-token surplus could not be sent to the
     * parent Personal Account (the token refused the transfer - RLUSD can freeze addresses)
     * and stays on the account. The repayment itself stands; a later {repay} retries the push.
     * @param parentPersonalAccount The parent Personal Account address that refused.
     * @param amount The surplus amount retained.
     */
    event LoanSurplusRetained(
        address indexed parentPersonalAccount,
        uint256 amount
    );

    /**
     * @notice Emitted when an authenticated action completes without executing. The bridged
     * FXRP that arrived with the message stays on the account, recoverable along the fixed
     * rails.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param operationId The payload's operation id. A duplicate was already consumed; an
     * expired skip leaves it unconsumed (the intent can retry under it).
     * @param reason The skip reason (see the `SKIP_REASON_*` constants).
     * @param guid The LayerZero message id the action arrived with.
     */
    event LoanActionSkipped(
        address indexed parentPersonalAccount,
        bytes32 operationId,
        uint8 reason,
        bytes32 guid
    );

    /**
     * @notice Reverts on a debt increase while new borrowing is disabled for this account's
     * subaccount type — the routine way a pool is sunset. Deliberately a revert, not a skip:
     * the condition is temporary-by-policy and a permissionless delivery must not consume
     * the packet.
     */
    error BorrowingDisabled();

    /**
     * @notice Reverts a debt increase before the subaccount type's fee recipient activates
     * its terms: a registered-but-unpriced type cannot take on debt. Retriable - the packet
     * is not consumed by this temporary condition.
     */
    error FeeTermsNotConfigured();

    /**
     * @notice Reverts if there are no idle loan tokens.
     */
    error NothingToRepay();

    /**
     * @notice Reverts if there is no idle FXRP to deposit.
     */
    error NothingToDeposit();

    /**
     * @notice Reverts if the OFT's live peer for the origin chain no longer matches the pinned
     * one; the return leg fails closed instead of bridging toward an unknown remote OApp.
     */
    error WrongOriginPeer();

    /**
     * @notice Reverts if the delivered compose value does not cover the return leg's LayerZero
     * messaging fee.
     * @param required The required fee.
     */
    error InsufficientFundsForBridgeHome(
        uint256 required
    );

    /**
     * @notice Reverts if excess or skipped compose value could not be forwarded to the parent
     * (this account has no native exit); the delivery stays retriable.
     */
    error RefundFailed();

    /**
     * @notice Reverts a withdraw delivered below its signed compose-value floor, so that an
     * underfunded permissionless delivery cannot consume the packet - not even as a terminal
     * skip. Retriable.
     * @param required The signed delivery-value floor.
     */
    error InsufficientDeliveryValue(
        uint256 required
    );

    /**
     * @notice Reverts a withdraw or borrow action that would leave the position uncovered: the
     * collateral remaining after it, at the market oracle's price, would be worth less than
     * `1.155 / LLTV` of the live debt plus twice the collectible fee (a dead or zero-priced
     * oracle values it at nothing). Retriable: repay - loan tokens to the account and {repay} -
     * or sign a smaller withdrawal or borrow, then retry.
     * @param requiredCover The collateral value the gate demands, in loan tokens.
     * @param remainingValue The value the action would have left, in loan tokens; zero under
     * a dead or zero-priced oracle.
     */
    error InsufficientRemainingCollateral(
        uint256 requiredCover,
        uint256 remainingValue
    );

    /**
     * @notice Reverts on a borrow with an unsupported destination kind (the Wormhole-to-XRPL
     * kind is reserved but not implemented).
     * @param destinationKind The unsupported destination kind.
     */
    error UnsupportedDestinationKind(
        uint8 destinationKind
    );

    /**
     * @notice Reverts on a borrow that names a delivery-value floor for a destination kind that
     * spends no compose value on this chain. Every kind V1 supports disburses without spending
     * value, so the floor must be zero; the field is reserved in the frozen payload for a kind
     * that pays for its own onward delivery. The Flare sender refuses the same instruction
     * before any bridge fee is paid.
     */
    error UnexpectedDeliveryValueFloor();

    /**
     * @notice Reverts on a borrow disbursement destination that is not a clean zero-padded
     * EVM address, or is zero or this account.
     */
    error InvalidDestination();

    /**
     * @notice Reverts on an action carrying no amount: a borrow with a zero borrow amount, a
     * deposit with no bridged amount, or a withdraw of zero.
     */
    error ZeroAmount();

    /**
     * @notice Reverts if a withdraw's signed arrival floor for the return leg is not one the
     * withdrawal can honor: zero, or above the amount being withdrawn.
     * @param amount The amount being withdrawn and bridged home.
     * @param minAmountReceived The floor the instruction signed.
     */
    error InvalidMinAmountReceived(
        uint256 amount,
        uint256 minAmountReceived
    );

    /**
     * @notice Repays the account's debt and the accrued Flare fee with its idle loan-token
     * balance: a payment short of the two is split pro rata between them, a covering one
     * closes the debt, attempts the whole collectible (reserving anything unpaid) and returns
     * the surplus to the parent.
     * @dev Permissionless and pause-exempt throughout: the debt reduction only moves the
     * account's own position toward safety, and the fee legs only move money to Flare's own
     * recipient. It checkpoints before the repayment and re-syncs
     * the canonical debt after (see {checkpointFee}). With live debt `D` and collectible fee
     * `F`, interest accrues, then a balance `P < D + F` pays `P × F / (D + F)` (rounded down)
     * to the fee recipient first and repays Morpho with the rest - by exact borrow shares when
     * that rest covers the debt (no over-repay revert), otherwise by assets; a balance covering
     * `D + F` closes the debt by exact shares and attempts the whole collectible from the
     * remainder. Every fee payment is best-effort, never held by the pause (an overcharge
     * would land on Flare's own recipient and is refundable), never rolling back the
     * repayment ({LoanFeeCollected}; the fee debt shrinks only by the
     * successfully requested transfer, conventional ERC-20 semantics being a
     * market-registration policy): a share that cannot be paid stays in the balance and
     * repays debt ({LoanFeeDeferred}), and once debt-free the remainder is attempted again,
     * with as much of it as the outstanding fee needs reserved here ({LoanFeeReserved}). Only
     * the unreserved balance is pushed to the parent once debt-free ({LoanSurplusRecovered};
     * best-effort, {LoanSurplusRetained} on refusal). Settling both claims through this rail
     * therefore costs the live debt plus the collectible fee, from one balance in one call; a
     * payment that covers the debt but not the fee leaves a pro-rata sliver of both, unless
     * the debt closes for less: a paid share's round-down can leave exactly the debt (possible
     * within roughly `F / D` base units of `D + F`), and a deferred share leaves the full
     * payment available, which may cover it - Morpho then consumes exactly the debt and the
     * tail handles any remainder, with fee still outstanding. The default route pays the fee
     * alongside the debt; repaying Morpho directly, on this account's behalf, pays the debt
     * alone.
     * @return _assets The assets repaid.
     */
    function repay()
        external
        returns (uint256 _assets);

    /**
     * @notice Runs a bare fee checkpoint: prices the elapsed period at the snapshotted
     * terms, adds the result to the fee debt, and re-baselines (principal to the canonical
     * live debt, clock to now, snapshot to the current terms).
     * @dev Permissionless and pause-exempt - notably the liquidated account's relief: an
     * external repayment or liquidation lowers the debt without the account seeing it, so the
     * floor keeps accruing on the stale principal until someone checkpoints, and only
     * prospectively; a liquidation's interest is still estimated from the recorded shares.
     * Under unchanged terms and non-decreasing debt, splitting a period typically increases
     * the total fee and never decreases it by more than one X18 unit (under 1e-18 of a base
     * unit) per checkpoint, so checkpointing cannot be used against the protocol; the
     * advertised promise is that per-checkpoint measurement. Shares-first: zero principal
     * makes no Morpho call, zero live shares read Morpho's stored totals without touching the IRM.
     */
    function checkpointFee()
        external;

    /**
     * @notice Deposits the whole idle FXRP balance as collateral into the account's position.
     * @dev Permissionless with a fixed destination (the account's own position): the retry
     * rail for FXRP that arrived without a successful composed action. It remains available
     * while paused only to defend a position with live debt; a debt-free deposit is new
     * exposure and is pause-gated. With a principal it checkpoints the fee first, and when that
     * has to accrue (live shares, time elapsed) Morpho's accrual must succeed, as for {repay};
     * the fee itself is never paid or gated here.
     * @return _amount The amount deposited.
     */
    function depositIdleFxrp()
        external
        returns (uint256 _amount);

    /**
     * @notice Returns the account's fee state, as of the last checkpoint or post-action
     * sync (stored values, not a live projection - run {checkpointFee} first for current
     * numbers).
     * @return _principal The canonical Morpho debt at the last checkpoint or sync (base
     * units).
     * @return _feeDebtX18 The accrued, uncollected fee at WAD precision (base units × 1e18);
     * the fractional part below one base unit is carried, never discarded.
     * @return _collectible The fee payable now: `_feeDebtX18 / 1e18`, whole base units.
     * @return _lastCheckpoint The last checkpoint's timestamp.
     * @return _feeFloor The snapshotted floor the next elapsed period is priced at (WAD).
     * @return _feeSpread The snapshotted spread the next elapsed period is priced at (WAD).
     */
    function getLoanFeeState()
        external view
        returns (
            uint256 _principal,
            uint256 _feeDebtX18,
            uint256 _collectible,
            uint64 _lastCheckpoint,
            uint64 _feeFloor,
            uint64 _feeSpread
        );

    /**
     * @notice The position projected to the current block - see {LoanPosition}. Reverts with the
     * market's rate model when it does, and where canonical accrual would overflow (a dead IRM
     * blocks every debt-bearing action anyway); a dead oracle is reported, not thrown.
     */
    function getLoanPosition()
        external view
        returns (LoanPosition memory);

    /**
     * @notice The cover gate's and the pool's bounds on the next borrow and withdrawal - see
     * {LoanLimits}.
     * @param _additionalCollateral Collateral a borrow packet would bring, counted as supplied.
     */
    function getLoanLimits(
        uint256 _additionalCollateral
    )
        external view
        returns (LoanLimits memory);

    /**
     * @notice The expected outcome of a {repay} over the loan tokens on the account plus
     * `_additionalLoanToken` - see {RepayPreview}. Oracle-free, and shares-first like {repay}: a
     * debt-free account's preview reads no rate model either.
     * @param _additionalLoanToken The top-up to preview; zero previews the idle balance alone.
     */
    function previewRepay(
        uint256 _additionalLoanToken
    )
        external view
        returns (RepayPreview memory);

    /**
     * @notice Whether a withdrawal of `_amount` passes the cover gate now, and the smallest
     * top-up whose {repay} would make it pass - see {WithdrawPreview}.
     * @param _amount The collateral to withdraw, in collateral-token base units.
     */
    function previewWithdraw(
        uint256 _amount
    )
        external view
        returns (WithdrawPreview memory);

    /**
     * @notice Whether a borrow of `_amount` passes the cover gate now, once the idle collateral
     * and `_additionalCollateral` are supplied - see {BorrowPreview}.
     * @param _amount The loan tokens to borrow.
     * @param _additionalCollateral Collateral the borrow packet would bring, counted as supplied.
     */
    function previewBorrow(
        uint256 _amount,
        uint256 _additionalCollateral
    )
        external view
        returns (BorrowPreview memory);
}
