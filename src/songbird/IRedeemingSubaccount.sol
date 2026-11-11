// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {ISubaccount} from "./ISubaccount.sol";

/**
 * @title IRedeemingSubaccount
 * @notice The surface every Flare subaccount type whose idle FXRP means one thing - home -
 * shares: the permissionless rail `sweepRedeem`, which pushes the whole balance to the parent
 * Personal Account and has it redeemed to the XRPL owner. Home is the only public direction on
 * such an account. Every entry a type gives the redemption pays the same price - the
 * controller's executor fee - and redeems the same balance; what becomes of a balance FAssets
 * will not redeem is the parent's decision ({IPersonalAccount.redeemFromSubaccount}).
 */
interface IRedeemingSubaccount is ISubaccount {

    /**
     * @notice Emitted when idle FXRP is pushed to the parent Personal Account and redeemed by
     * it to its XRPL owner.
     * @param parentPersonalAccount The parent Personal Account address (the redeemer).
     * @param amount Amount of FXRP pushed and requested for redemption (the whole balance,
     * from whichever entry).
     * @param redeemedAmount Amount of FXRP actually redeemed, which can be less; the rest
     * stays on the parent, or came back here when it is itself redeemable, for the next sweep.
     */
    event FXrpRedeemed(
        address indexed parentPersonalAccount,
        uint256 amount,
        uint256 redeemedAmount
    );

    /**
     * @notice Emitted when a redemption pushed a balance FAssets will not redeem - below its
     * minimum - to the parent Personal Account, which kept it unredeemed (in place of
     * {FXrpRedeemed}).
     * @param parentPersonalAccount The parent Personal Account address.
     * @param token The FXRP token.
     * @param amount The pushed amount.
     */
    event TokenSweptToParent(
        address indexed parentPersonalAccount,
        address indexed token,
        uint256 amount
    );

    /**
     * @notice Emitted when the value a redemption carried stayed with the parent Personal
     * Account instead of being spent as the executor fee: nothing was redeemed, so the parent
     * kept it.
     * @param parentPersonalAccount The parent Personal Account address.
     * @param amount The amount sent.
     */
    event NativeSweptToParent(
        address indexed parentPersonalAccount,
        uint256 amount
    );

    /**
     * @notice Reverts on an empty account: a redeem-home packet whose credit a sweep already
     * moved stays retriable, and a caller's value is returned rather than trapped.
     */
    error NothingToRedeem();

    /**
     * @notice Reverts if the value a redemption carries - `msg.value` on {sweepRedeem}, the
     * compose value on a type's authenticated entry - is below the controller's executor fee.
     * @param executorFee The required value.
     */
    error InsufficientFundsForRedeem(
        uint256 executorFee
    );

    /**
     * @notice Redeems all idle FXRP through the parent Personal Account, to its XRPL owner.
     * @dev Permissionless and parameterless: the destination is the parent (fixed at
     * deployment, part of this account's address), which pulls exactly the pushed amount and
     * requests its redemption through {IPersonalAccount-redeemFromSubaccount} - never more, so
     * its own balance stays out of it - so every outcome - a partial fill when FAssets tickets
     * run out, a payment-default payout, a refund - remains under the user's control.
     * `msg.value` must reach the controller's configured executor fee
     * ({InsufficientFundsForRedeem}; the price of the permissionless rail, and of every other
     * entry to the same redemption) and travels whole as the FAssets executor fee (recorded in
     * whole gwei). The whole balance is redeemed rather than whole lots; an empty account
     * reverts ({NothingToRedeem}). A balance below the FAssets minimum the parent keeps
     * unredeemed, with the value ({TokenSweptToParent} and {NativeSweptToParent} in place of
     * {FXrpRedeemed}, `_redeemedAmount` zero); an unfilled remainder of a partial fill comes
     * back here when it is itself redeemable, and stays on the parent otherwise.
     * @return _amount The balance the sweep saw (the whole balance).
     * @return _redeemedAmount Amount of FXRP actually redeemed; zero when FAssets redeemed none.
     */
    function sweepRedeem()
        external payable
        returns (uint256 _amount, uint256 _redeemedAmount);
}
