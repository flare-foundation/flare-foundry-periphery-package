// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {ILayerZeroComposer} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol";
import {IControlledAccount} from "./IControlledAccount.sol";

/// @dev Compose payload schema version 1, shared by every compose receiver on either
/// chain. The payload is `abi.encode(uint8 version, uint8 action, bytes actionData)`; the
/// action space is defined per receiving contract.
uint8 constant PAYLOAD_VERSION_1 = 1;

/// @dev Skip reason: the operation id was already consumed (a retried instruction delivered
/// twice must not turn one intended action into two).
uint8 constant SKIP_REASON_DUPLICATE = 1;

/// @dev Skip reason: the deadline passed before delivery; the user's intent is stale. The
/// operation id is not consumed, so the same intent can be retried with a fresh deadline.
uint8 constant SKIP_REASON_EXPIRED = 2;

/**
 * @title IComposeReceiverAccountBase
 * @notice The shared authenticated `lzCompose` surface of the same-address cross-chain
 * accounts: the loan-chain subaccount and Personal Account (Ethereum, at launch), and the Flare
 * loan subaccount as the receiver of its own bridge-back. It authenticates the endpoint, the
 * OFT, the origin chain, the pinned peer and `composeFrom`, and tracks replay state for the
 * signed actions (an id-less action, such as the Flare redeem-home - which itself originates
 * from a signed withdraw - carries no id and relies on the endpoint's at-most-once
 * compose delivery). Users are XRPL-only and their
 * signatures become on-chain authority only on Flare, so every action arriving here was sent by
 * this same address on the other chain — the account's own twin. Account-specific
 * parent-driven and public rails live outside this interface.
 */
interface IComposeReceiverAccountBase is ILayerZeroComposer, IControlledAccount {

    /**
     * @notice Reverts if `lzCompose` is called by anything other than the LayerZero endpoint.
     */
    error OnlyEndpoint();

    /**
     * @notice Reverts if native value is attached to `lzCompose` for an action that does not
     * spend it within the same call. Rejecting it keeps a mistaken delivery retriable without
     * value; an action that spends or forwards the value in the same call opts in (the Flare
     * redeem-on-arrival, the loan-chain atomic withdraw).
     */
    error NonZeroComposeValue();

    /**
     * @notice Reverts if the compose sender (`_from`) is not the configured FXRP OFT.
     * @param from The compose sender.
     */
    error WrongComposeSender(
        address from
    );

    /**
     * @notice Reverts if the composed message did not originate on the configured origin chain.
     * @param srcEid The source endpoint id of the message.
     */
    error WrongSourceEid(
        uint32 srcEid
    );

    /**
     * @notice Reverts if the source-chain sender of the composed message is not this account
     * itself (its own address on the origin chain).
     * @param composeFrom The source-chain sender.
     */
    error WrongComposeFrom(
        bytes32 composeFrom
    );

    /**
     * @notice Reverts if the delivered GUID does not equal the one recomputed from the pinned
     * origin peer: the compose wrapper alone does not commit to the source OApp, so this
     * check is what binds the message to the pinned peer.
     * @param guid The delivered GUID.
     */
    error WrongGuid(
        bytes32 guid
    );

    /**
     * @notice Reverts on a payload with an unsupported schema version.
     * @param version The unsupported version.
     */
    error UnsupportedPayloadVersion(
        uint8 version
    );

    /**
     * @notice Reverts on a payload with an unsupported action.
     * @param action The unsupported action.
     */
    error UnsupportedAction(
        uint8 action
    );

    /**
     * @notice Reverts on a payload whose operation id is zero.
     */
    error InvalidOperationId();

    /**
     * @notice Returns whether an operation id has been consumed. An id is consumed on
     * execution; an expired skip leaves it unconsumed (the intent can retry under it), and a
     * duplicate skip means it was already consumed. Derived accounts may consume ids for
     * their own terminal reasons (see each account's skip reasons).
     * @param _operationId The operation id.
     * @return Whether the operation id is consumed.
     */
    function usedOperations(
        bytes32 _operationId
    )
        external view
        returns (bool);
}
