// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import {IPayment} from ".//IPayment.sol";
import {IReferencedPaymentNonexistence} from ".//IReferencedPaymentNonexistence.sol";
import {IConfirmedBlockHeightExists} from ".//IConfirmedBlockHeightExists.sol";
import {IAddressValidity} from ".//IAddressValidity.sol";
import {RedemptionTicketInfo} from "./data/RedemptionTicketInfo.sol";
import {RedemptionRequestInfo} from "./data/RedemptionRequestInfo.sol";

/**
 * Periphery-defined view of IAssetManager.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IAssetManagerRedemption {
    /**
     * Redeem (up to) `_lots` lots of f-assets. The corresponding amount of the f-assets belonging
     * to the redeemer will be burned and the redeemer will get paid by the agent in underlying currency
     * (or, in case of agent's payment default, by agent's collateral with a premium).
     * NOTE: in some cases not all sent f-assets can be redeemed (either there are not enough tickets or
     * more than a fixed limit of tickets should be redeemed). In this case only part of the approved assets
     * are burned and redeemed and the redeemer can execute this method again for the remaining lots.
     * In such a case the `RedemptionRequestIncomplete` event will be emitted, indicating the number
     * of remaining lots.
     * Agent receives redemption request id and instructions for underlying payment in
     * RedemptionRequested event and has to pay `value - fee` and use the provided payment reference.
     * NOTE: if the underlying block isn't updated regularly, it can happen that there is no time for underlying
     * payment. Since the agents cannot know when the next redemption will happen, they should regularly update the
     * underlying time by obtaining fresh proof of latest underlying block and calling `updateCurrentBlock`.
     * @param _lots number of lots to redeem
     * @param _redeemerUnderlyingAddressString the address to which the agent must transfer underlying amount
     * @param _executor the account that is allowed to execute redemption default (besides redeemer and agent)
     * @return _redeemedAmountUBA the actual redeemed amount; may be less than requested if there are not enough
     *      redemption tickets available or the maximum redemption ticket limit is reached
     */
    function redeem(
        uint256 _lots,
        string memory _redeemerUnderlyingAddressString,
        address payable _executor
    ) external payable
        returns (uint256 _redeemedAmountUBA);

    /**
     * If the redeemer provides invalid address, the agent should provide the proof of address invalidity from the
     * Flare data connector. With this, the agent's obligations are fulfilled and they can keep the underlying.
     * NOTE: may only be called by the owner of the agent vault in the redemption request
     * NOTE: also checks that redeemer's address is normalized, so the redeemer must normalize their address,
     *   otherwise it will be rejected!
     * @param _proof proof that the address is invalid
     * @param _redemptionRequestId id of an existing redemption request
     */
    function rejectInvalidRedemption(
        IAddressValidity.Proof calldata _proof,
        uint256 _redemptionRequestId
    ) external;

    /**
     * After paying to the redeemer, the agent must call this method to unlock the collateral
     * and to make sure that the redeemer cannot demand payment in collateral on timeout.
     * The same method must be called for any payment status (SUCCESS, FAILED, BLOCKED).
     * In case of FAILED, it just releases the agent's underlying funds and the redeemer gets paid in collateral
     * after calling redemptionPaymentDefault.
     * In case of SUCCESS or BLOCKED, remaining underlying funds and collateral are released to the agent.
     * If the agent doesn't confirm payment in enough time (several hours, setting
     * `confirmationByOthersAfterSeconds`), anybody can do it and get rewarded from the agent's vault.
     * NOTE: may only be called by the owner of the agent vault in the redemption request
     *   except if enough time has passed without confirmation - then it can be called by anybody
     * @param _payment proof of the underlying payment (must contain exact `value - fee` amount and correct
     *      payment reference)
     * @param _redemptionRequestId id of an existing redemption request
     */
    function confirmRedemptionPayment(
        IPayment.Proof calldata _payment,
        uint256 _redemptionRequestId
    ) external;

    /**
     * If the agent doesn't transfer the redeemed underlying assets in time (until the last allowed block on
     * the underlying chain), the redeemer calls this method and receives payment in collateral (with some extra).
     * The agent can also call default if the redeemer is unresponsive, to payout the redeemer and free the
     * remaining collateral.
     * NOTE: The attestation request must be done with `checkSourceAddresses=false`.
     * NOTE: may only be called by the redeemer (= creator of the redemption request),
     *   the executor appointed by the redeemer,
     *   or the agent owner (= owner of the agent vault in the redemption request)
     * @param _proof proof that the agent didn't pay with correct payment reference on the underlying chain
     * @param _redemptionRequestId id of an existing redemption request
     */
    function redemptionPaymentDefault(
        IReferencedPaymentNonexistence.Proof calldata _proof,
        uint256 _redemptionRequestId
    ) external;

    /**
     * If the agent hasn't performed the payment, the agent can close the redemption request to free underlying funds.
     * It can be done immediately after the redeemer or agent calls `redemptionPaymentDefault`,
     * or this method can trigger the default payment without proof, but only after enough time has passed so that
     * attestation proof of non-payment is not available any more.
     * NOTE: may only be called by the owner of the agent vault in the redemption request.
     * @param _proof proof that the attestation query window can not not contain
     *      the payment/non-payment proof anymore
     * @param _redemptionRequestId id of an existing, but already defaulted, redemption request
     */
    function finishRedemptionWithoutPayment(
        IConfirmedBlockHeightExists.Proof calldata _proof,
        uint256 _redemptionRequestId
    ) external;

    /**
     * Returns the data about an ongoing redemption request.
     * Note: once the redemptions is confirmed, the request is deleted and this method fails.
     * However, if there is no payment and the redemption defaults, the method works and returns status DEFAULTED.
     * @param _redemptionRequestId the redemption request id, as used for confirming or defaulting the redemption
     */
    function redemptionRequestInfo(uint256 _redemptionRequestId)
        external view
        returns (RedemptionRequestInfo.Data memory);

    /**
     * Agent can "redeem against himself" by calling `selfClose`, which burns agent's own f-assets
     * and unlocks agent's collateral. The underlying funds backing the f-assets are released
     * as agent's free underlying funds and can be later withdrawn after announcement.
     * NOTE: may only be called by the agent vault owner.
     * @param _agentVault agent vault address
     * @param _amountUBA amount of f-assets to self-close
     * @return _closedAmountUBA the actual self-closed amount, may be less than requested if there are not enough
     *      redemption tickets available or the maximum redemption ticket limit is reached
     */
    function selfClose(
        address _agentVault,
        uint256 _amountUBA
    ) external
        returns (uint256 _closedAmountUBA);

    /**
     * Return (part of) the redemption queue.
     * @param _firstRedemptionTicketId the ticket id to start listing from; if 0, starts from the beginning
     * @param _pageSize the maximum number of redemption tickets to return
     * @return _queue the (part of) the redemption queue; maximum length is _pageSize
     * @return _nextRedemptionTicketId works as a cursor - if the _pageSize is reached and there are more tickets,
     *  it is the first ticket id not returned; if the end is reached, it is 0
     */
    function redemptionQueue(
        uint256 _firstRedemptionTicketId,
        uint256 _pageSize
    ) external view
        returns (RedemptionTicketInfo.Data[] memory _queue, uint256 _nextRedemptionTicketId);

    /**
     * Return (part of) the redemption queue for a specific agent.
     * @param _agentVault the agent vault address of the queried agent
     * @param _firstRedemptionTicketId the ticket id to start listing from; if 0, starts from the beginning
     * @param _pageSize the maximum number of redemption tickets to return
     * @return _queue the (part of) the redemption queue; maximum length is _pageSize
     * @return _nextRedemptionTicketId works as a cursor - if the _pageSize is reached and there are more tickets,
     *  it is the first ticket id not returned; if the end is reached, it is 0
     */
    function agentRedemptionQueue(
        address _agentVault,
        uint256 _firstRedemptionTicketId,
        uint256 _pageSize
    ) external view
        returns (RedemptionTicketInfo.Data[] memory _queue, uint256 _nextRedemptionTicketId);

    /**
     * Due to the minting pool fees or after a lot size change by the governance,
     * it may happen that less than one lot remains on a redemption ticket. This is named "dust" and
     * can be self closed or liquidated, but not redeemed. However, after several additions,
     * the total dust can amount to more than one lot. Using this method, the amount, rounded down
     * to a whole number of lots, can be converted to a new redemption ticket.
     * NOTE: we do NOT check that the caller is the agent vault owner, since we want to
     * allow anyone to convert dust to tickets to increase asset fungibility.
     * NOTE: dust above 1 lot is actually added to ticket at every minting, so this function need
     * only be called when the agent doesn't have any minting.
     * @param _agentVault agent vault address
     */
    function convertDustToTicket(
        address _agentVault
    ) external;

    /**
     * If lot size is increased, there may be many tickets less than one lot in the queue.
     * In extreme cases, this could prevent redemptions, if there weren't any tickets above 1 lot
     * among the first `maxRedeemedTickets` tickets.
     * To fix this, call this method. It converts small tickets to dust and when the dust exceeds one lot
     * adds it to the ticket.
     * NOTE: this method can be called by the governance or its executor.
     * @param _firstTicketId if nonzero, the ticket id of starting ticket; if zero, the starting ticket will
     *   be the redemption queue's first ticket id.
     *   When the method finishes, it emits RedemptionTicketsConsolidated event with the nextTicketId
     *   parameter. If it is nonzero, the method should be invoked again with this value as _firstTicketId.
     */
    function consolidateSmallTickets(
        uint256 _firstTicketId
    ) external;

    /**
     * Redeemer started the redemption process and provided fassets.
     * The amount of fassets corresponding to valueUBA was burned.
     * Several RedemptionRequested events are emitted, one for every agent redeemed against
     * (but multiple tickets for the same agent are combined).
     * The agent's collateral is still locked.
     */
    event RedemptionRequested(
        address indexed agentVault,
        address indexed redeemer,
        uint256 indexed requestId,
        string paymentAddress,
        uint256 valueUBA,
        uint256 feeUBA,
        uint256 firstUnderlyingBlock,
        uint256 lastUnderlyingBlock,
        uint256 lastUnderlyingTimestamp,
        bytes32 paymentReference,
        address executor,
        uint256 executorFeeNatWei);

    /**
     * Agent rejected the redemption payment because the redeemer's address is invalid.
     */
    event RedemptionRejected(
        address indexed agentVault,
        address indexed redeemer,
        uint256 indexed requestId,
        uint256 redemptionAmountUBA);

    /**
     * In case there were not enough tickets or more than allowed number would have to be redeemed,
     * only partial redemption is done and the `remainingLots` lots of the fassets are returned to
     * the redeemer.
     */
    event RedemptionRequestIncomplete(
        address indexed redeemer,
        uint256 remainingLots);

    /**
     * Agent provided proof of redemption payment.
     * Agent's collateral is released.
     */
    event RedemptionPerformed(
        address indexed agentVault,
        address indexed redeemer,
        uint256 indexed requestId,
        bytes32 transactionHash,
        uint256 redemptionAmountUBA,
        int256 spentUnderlyingUBA);

    /**
     * The time for redemption payment is over and payment proof was not provided.
     * Redeemer was paid in the collateral (with extra).
     * The rest of the agent's collateral is released.
     * The corresponding amount of underlying currency, held by the agent, is released
     * and the agent can withdraw it (after underlying withdrawal announcement).
     */
    event RedemptionDefault(
        address indexed agentVault,
        address indexed redeemer,
        uint256 indexed requestId,
        uint256 redemptionAmountUBA,
        uint256 redeemedVaultCollateralWei,
        uint256 redeemedPoolCollateralWei);

    /**
     * Agent provided the proof that redemption payment was attempted, but failed due to
     * the redeemer's address being blocked (or burning more than allowed amount of gas).
     * Redeemer is not paid and all of the agent's collateral is released.
     * The underlying currency is also released to the agent.
     */
    event RedemptionPaymentBlocked(
        address indexed agentVault,
        address indexed redeemer,
        uint256 indexed requestId,
        bytes32 transactionHash,
        uint256 redemptionAmountUBA,
        int256 spentUnderlyingUBA);

    /**
     * Agent provided the proof that redemption payment was attempted, but failed due to
     * his own error. Also triggers payment default, unless the redeemer has done it already.
     */
    event RedemptionPaymentFailed(
        address indexed agentVault,
        address indexed redeemer,
        uint256 indexed requestId,
        bytes32 transactionHash,
        int256 spentUnderlyingUBA,
        string failureReason);

    /**
     * At the end of a successful redemption, part of the redemption fee is re-minted as FAssets
     * and paid to the agent's collateral pool as fee.
     */
    event RedemptionPoolFeeMinted(
        address indexed agentVault,
        uint256 indexed requestId,
        uint256 poolFeeUBA);

    /**
     * Due to self-close exit, some of the agent's backed fAssets were redeemed,
     * but the redemption was immediately paid in collateral so no redemption process is started.
     */
    event RedeemedInCollateral(
        address indexed agentVault,
        address indexed redeemer,
        uint256 redemptionAmountUBA,
        uint256 paidVaultCollateralWei);

    /**
     * Agent self-closed valueUBA of backing fassets.
     */
    event SelfClose(
        address indexed agentVault,
        uint256 valueUBA);

    /**
     * Redemption ticket with given value was created (when minting was executed).
     */
    event RedemptionTicketCreated(
        address indexed agentVault,
        uint256 indexed redemptionTicketId,
        uint256 ticketValueUBA);

    /**
     * Redemption ticket value was changed (partially redeemed).
     * @param ticketValueUBA the ticket value after update
     */
    event RedemptionTicketUpdated(
        address indexed agentVault,
        uint256 indexed redemptionTicketId,
        uint256 ticketValueUBA);

    /**
     * Redemption ticket was deleted.
     */
    event RedemptionTicketDeleted(
        address indexed agentVault,
        uint256 indexed redemptionTicketId);

    /**
     * Method `consolidateSmallTickets` has finished.
     * @param firstTicketId first handled ticket id (different from the method param _firstTicketId if it was 0).
     * @param nextTicketId the first remaining (not handled) ticket id, or 0 if the end of queue was reached.
     */
    event RedemptionTicketsConsolidated(
        uint256 firstTicketId,
        uint256 nextTicketId);

    /**
     * Due to lot size change, some dust was created for this agent during
     * redemption. Value `dustUBA` is the new amount of dust. Dust cannot be directly redeemed,
     * but it can be self-closed or liquidated and if it accumulates to more than 1 lot,
     * it can be converted to a new redemption ticket.
     */
    event DustChanged(
        address indexed agentVault,
        uint256 dustUBA);
}
