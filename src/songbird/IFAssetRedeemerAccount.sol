// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IReferencedPaymentNonexistence} from "./IReferencedPaymentNonexistence.sol";
import {IXRPPaymentNonexistence} from "./IXRPPaymentNonexistence.sol";

/**
 * @title IFAssetRedeemerAccount
 * @notice User interface for per-redeemer account operations.
 */
interface IFAssetRedeemerAccount {

    /**
     * @notice Emitted when a redeem call succeeds.
     * @param amountToRedeemUBA Amount to redeem in UBA.
     * @param redeemerUnderlyingAddress Underlying destination address for redeem.
     * @param redeemWithTag Indicates whether `redeemWithTag` or `redeemAmount` was called on the asset manager.
     * @param destinationTag Destination tag used for redeem, if applicable.
     * @param executor Executor address used for redeem.
     * @param executorFee Executor fee passed with compose message.
     * @param redeemedAmountUBA Amount redeemed in UBA reported by asset manager.
     */
    event FAssetRedeemed(
        uint256 amountToRedeemUBA,
        string redeemerUnderlyingAddress,
        bool redeemWithTag,
        uint256 destinationTag,
        address executor,
        uint256 executorFee,
        uint256 redeemedAmountUBA
    );

    /**
     * @notice Emitted when allowances are set to max from account to owner.
     * @param owner Owner of redeemer account.
     * @param fAsset FAsset token.
     * @param stableCoin Stable coin token.
     * @param wNat Wrapped native token.
     */
    event MaxAllowancesSet(
        address indexed owner,
        IERC20 fAsset,
        IERC20 stableCoin,
        IERC20 wNat
    );

    /**
     * @notice Emitted when the owner triggers `redemptionPaymentDefault` on the asset manager.
     * @param redemptionRequestId Redemption request id passed to the asset manager.
     */
    event RedemptionPaymentDefaulted(uint256 indexed redemptionRequestId);

    /**
     * @notice Emitted when the owner triggers `xrpRedemptionPaymentDefault` on the asset manager.
     * @param redemptionRequestId Redemption request id passed to the asset manager.
     */
    event XrpRedemptionPaymentDefaulted(uint256 indexed redemptionRequestId);

    /**
     * @notice Reverts when a required address is zero.
     */
    error InvalidAddress();

    /**
     * @notice Reverts when caller is not the composer.
     */
    error ComposerOnly();

    /**
     * @notice Reverts when caller is not the account owner.
     */
    error OwnerOnly();

    /**
     * @notice Reverts when initialize is called more than once.
     */
    error AlreadyInitialized();

    /**
     * @notice Reverts when redeem with tag is attempted on asset manager that does not support it.
     */
    error RedeemWithTagNotSupported();

    /**
     * @notice Triggers `redemptionPaymentDefault` on the asset manager for a redemption initiated
     *         by this account. Can only be called by the account owner.
     * @dev Asset manager is read from the composer; reverts bubble up to the caller.
     * @param _proof Proof of non-payment with correct payment reference on the underlying chain.
     * @param _redemptionRequestId Id of an existing redemption request initiated by this account.
     */
    function redemptionPaymentDefault(
        IReferencedPaymentNonexistence.Proof calldata _proof,
        uint256 _redemptionRequestId
    )
        external;

    /**
     * @notice Triggers XRP-specific variant of `redemptionPaymentDefault`.
     *         Can only be called by the account owner.
     * @dev Asset manager is read from the composer; reverts bubble up to the caller.
     * @param _proof Proof of non-payment on the XRP chain.
     * @param _redemptionRequestId Id of an existing redemption request initiated by this account.
     */
    function xrpRedemptionPaymentDefault(
        IXRPPaymentNonexistence.Proof calldata _proof,
        uint256 _redemptionRequestId
    )
        external;

    /**
     * @notice Returns the owner of the redeemer account.
     * @return The address of the owner.
     */
    function owner() external view returns (address);

    /**
     * @notice Returns the composer associated with the redeemer account.
     * @return The address of the composer.
     */
    function composer() external view returns (address);
}
