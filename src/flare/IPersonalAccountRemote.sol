// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IComposeReceiverAccountBase} from "./IComposeReceiverAccountBase.sol";
import {IPersonalAccountBase} from "./IPersonalAccountBase.sol";

/// @dev Execute action: `actionData` is `abi.encode(bytes32 operationId, uint64 deadline,
/// Call[] calls)`. Executes the signed calls from this account in order and atomically for
/// calls that revert - the remote form of the Flare `executeUserOp`, carried by the
/// authenticated compose instead of the controller, with the user's XRPL signature covering
/// every target, value and calldata. Return data is not interpreted, matching Flare's
/// `executeUserOp`: a callee that reports failure by returning `false` (some ERC-20s) or a
/// codeless target counts as a successful call, so the wallet must know the callee's success
/// convention.
uint8 constant PA_ACTION_EXECUTE = 1;

/**
 * @title IPersonalAccountRemote
 * @notice User interface for the remote Personal Account: the implementation
 * registered behind the frozen PA proxy on a diamond other than Flare's (the loan chain,
 * Ethereum, at launch),
 * living at the same CREATE2 address as the user's Flare Personal Account. It has no local
 * owner and no controller-driven methods — instructions exist only on Flare — so every
 * authorized action arrives as an authenticated LayerZero compose message sent by this same
 * account on Flare (`sendCrossChainUserOp`). The action set is exactly one action: execute
 * a signed batch of calls, the way the Flare account executes `executeUserOp`. The blast
 * radius is therefore the same as a controller compromise on Flare: a compromised compose
 * root has the full on-chain authority of this address - balances, approvals, external
 * positions and any role granted to it - and over the loan subaccount no direct authority at
 * all: it has no parent-callable method, so Morpho collateral and debt stay behind the
 * subaccount's own compose authentication. There is
 * no permissionless rail: what arrives here (borrow proceeds the user directed here,
 * recovered loan-token surplus, strays, native delivered with a message to fund
 * value-carrying calls) moves only by the user's signature.
 */
interface IPersonalAccountRemote is IPersonalAccountBase, IComposeReceiverAccountBase {
    /// @notice One call of a signed batch. Field-identical to the Flare `IPersonalAccount.Call`
    /// (the sender encodes that struct, this account decodes this one - the same ABI layout).
    struct Call {
        /// @notice Target contract or recipient.
        address target;
        /// @notice Native value (in wei) to send with the call, from this account's balance.
        uint256 value;
        /// @notice Call data; empty for a plain native transfer.
        bytes data;
    }

    /**
     * @notice Emitted when a signed batch of calls executed.
     * @param operationId The user-chosen operation id, now consumed.
     * @param callCount The number of calls executed.
     * @param guid The LayerZero message id the action arrived with.
     */
    event UserOpExecuted(
        bytes32 operationId,
        uint256 callCount,
        bytes32 guid
    );

    /**
     * @notice Emitted when an authenticated action completes without executing.
     * @param operationId The payload's operation id. A duplicate was already consumed; an
     * expired skip leaves it unconsumed (the intent can retry under it).
     * @param reason The skip reason (see the `SKIP_REASON_*` constants).
     * @param guid The LayerZero message id the action arrived with.
     */
    event ActionSkipped(
        bytes32 operationId,
        uint8 reason,
        bytes32 guid
    );

    /**
     * @notice Reverts on an empty batch, which would only consume the operation id.
     */
    error EmptyUserOp();

    /**
     * @notice Reverts if a call of the batch fails: the whole delivery reverts (all or
     * nothing) and stays retriable at the endpoint, with the id unconsumed.
     * @param index The index of the call that failed.
     * @param returnData The return data of the failed call.
     */
    error CallFailed(
        uint256 index,
        bytes returnData
    );

    /**
     * @notice Reverts on the implementation contract itself, which is never initialized: it
     * must not accept native, since nothing could ever move it out again.
     */
    error NotInitialized();
}
