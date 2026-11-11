// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IComposeReceiverAccountBase} from "./IComposeReceiverAccountBase.sol";
import {ISubaccount} from "./ISubaccount.sol";

/**
 * @title IBridgingSubaccount
 * @notice The surface every Flare subaccount type that bridges FXRP to its own address on a
 * remote chain shares, whatever the type does there: the compose ingress of its own remote
 * twin's messages (see {IComposeReceiverAccountBase}), authenticated against the transport
 * derived from the type's bridge route, and the errors of the forward move every one of its
 * instructions is sent through. The instructions themselves, and what an arriving message
 * does, are declared on the type's interface (e.g. {ILoanSubaccount}); whether the type also
 * redeems its idle FXRP is a separate surface ({IRedeemingSubaccount}).
 */
interface IBridgingSubaccount is IComposeReceiverAccountBase, ISubaccount {

    /**
     * @notice Reverts if this subaccount's type has no complete bridge route on the controller:
     * no FXRP OFT adapter, a type never pinned to a remote chain, a suspended type, or a
     * cleared route.
     */
    error BridgeRouteNotConfigured();

    /**
     * @notice Reverts if the OFT's live peer for the destination chain no longer matches the
     * peer pinned in the controller's bridge route for this subaccount's type.
     */
    error WrongDestinationPeer();

    /**
     * @notice Reverts if the value sent with a forward move does not cover the LayerZero
     * messaging fee of the bridge.
     * @param messagingFee The required messaging fee.
     */
    error InsufficientFundsForBridge(
        uint256 messagingFee
    );

    /**
     * @notice Reverts if the caller's excess native refund could not be returned.
     */
    error RefundFailed();

    /**
     * @notice Reverts if a forward move's signed arrival floor is not one this send can honor:
     * above the amount it carries, or zero on a send that carries tokens.
     * @param amount The amount being sent.
     * @param minAmount The floor named by the instruction.
     */
    error InvalidMinAmount(
        uint256 amount,
        uint256 minAmount
    );

    /**
     * @notice Reverts if the requested bridge amount exceeds the account's FXRP balance.
     * @param amount The requested amount.
     * @param balance The account's FXRP balance.
     */
    error AmountExceedsBalance(
        uint256 amount,
        uint256 balance
    );
}
