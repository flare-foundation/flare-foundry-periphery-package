// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

import {IOwnableWithTimelock} from "./IOwnableWithTimelock.sol";
import {IAssetManager} from "./IAssetManager.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";
import {ILayerZeroComposer} from "@layerzerolabs/lz-evm-protocol-v2/contracts/interfaces/ILayerZeroComposer.sol";

/**
 * @title IFAssetRedeemComposer
 * @notice User interface for the LayerZero compose-based FAsset redeem orchestrator.
 * @dev Integration requirement for source-chain callers: `lzCompose` enforces
 * `msg.value >= RedeemComposeMessage.executorFee`; `send` does not. Callers must therefore
 * configure the `lzComposeOption` with a compose value of at least `executorFee`, or the
 * LayerZero executor may be under-incentivized to deliver `lzCompose` with the intended
 * `msg.value`, leaving the message unexecuted.
 */
interface IFAssetRedeemComposer is ILayerZeroComposer, IBeacon, IOwnableWithTimelock {

    /**
     * @notice Struct representing the LZ compose message for f-asset redemption.
     */
    struct RedeemComposeMessage {
        /// @notice EVM address that owns the per-redeemer account.
        address redeemer;
        /// @notice Underlying-chain redemption destination passed to the asset manager.
        string redeemerUnderlyingAddress;
        /// @notice Indicates whether to call `redeemWithTag` or `redeemAmount` on the asset manager.
        /// If true, asset manager must support it (checks `redeemWithTagSupported` - enabled only for XRP).
        bool redeemWithTag;
        /// @notice Destination tag. Only used if `redeemWithTag` is true.
        /// Only for XRP; it must fit in 32 bits for now.
        uint256 destinationTag;
        /// @notice Executor address used for redemption. If zero, default executor is used.
        address payable executor;
        /// @notice Executor fee (in wei) to be paid to the executor for executing the redeem on Flare.
        /// @dev `lzCompose` enforces `msg.value >= executorFee`; `send` does not. Callers must
        /// therefore configure the `lzComposeOption` with a compose value of at least `executorFee`,
        /// or the LayerZero executor may be under-incentivized to deliver `lzCompose` with the
        /// intended `msg.value`, leaving the message unexecuted.
        uint256 executorFee;
    }

    /**
     * @notice Token address and balance pair.
     */
    struct TokenBalance {
        /// @notice Token address.
        address token;
        /// @notice Token balance.
        uint256 balance;
    }

    /**
     * @notice Struct representing the balances of a redeemer account.
     */
    struct AccountBalances {
        /// @notice f-asset token and balance.
        TokenBalance fAsset;
        /// @notice Stable coin token and balance.
        TokenBalance stableCoin;
        /// @notice Wrapped native token and balance.
        TokenBalance wNat;
    }

    /**
     * @notice Emitted when the account beacon implementation is updated.
     * @param implementation New redeemer account implementation address.
     */
    event RedeemerAccountImplementationSet(address indexed implementation);

    /**
     * @notice Emitted when a redeem call succeeds.
     * @param guid LayerZero message GUID.
     * @param srcEid Source endpoint ID.
     * @param redeemer Redeemer account owner address.
     * @param redeemerAccount Deterministic redeemer account address.
     * @param amountToRedeemUBA Amount to redeem in UBA.
     * @param redeemerUnderlyingAddress Underlying destination address for redeem.
     * @param redeemWithTag Indicates whether `redeemWithTag` or `redeemAmount` was called on the asset manager.
     * @param destinationTag Destination tag used for redeem, if applicable.
     * @param executor Executor address used for redeem.
     * @param executorFee Executor fee passed with compose message.
     * @param redeemedAmountUBA Amount redeemed in UBA reported by asset manager.
     * @param wrappedAmount Amount of wrapped native tokens deposited to redeemer account.
     */
    event FAssetRedeemed(
        bytes32 indexed guid,
        uint32 indexed srcEid,
        address indexed redeemer,
        address redeemerAccount,
        uint256 amountToRedeemUBA,
        string redeemerUnderlyingAddress,
        bool redeemWithTag,
        uint256 destinationTag,
        address executor,
        uint256 executorFee,
        uint256 redeemedAmountUBA,
        uint256 wrappedAmount
    );

    /**
     * @notice Emitted when redeem call fails but token transfer to redeemer account already happened.
     * @param guid LayerZero message GUID.
     * @param srcEid Source endpoint ID.
     * @param redeemer Redeemer account owner address.
     * @param redeemerAccount Deterministic redeemer account address.
     * @param amountToRedeemUBA Amount to redeem in UBA.
     * @param wrappedAmount Amount of wrapped native tokens deposited to redeemer account in case of failure.
     */
    event FAssetRedeemFailed(
        bytes32 indexed guid,
        uint32 indexed srcEid,
        address indexed redeemer,
        address redeemerAccount,
        uint256 amountToRedeemUBA,
        uint256 wrappedAmount
    );

    /**
     * @notice Emitted when a new redeemer account is created.
     * @param redeemer Redeemer account owner address.
     * @param account Newly created deterministic account address.
     */
    event RedeemerAccountCreated(address indexed redeemer, address indexed account);

    /**
     * @notice Emitted when owner manually transfers f-asset from composer.
     * @param to Recipient account.
     * @param amount Amount transferred.
     */
    event FAssetTransferred(address indexed to, uint256 amount);

    /**
     * @notice Emitted when default executor is set.
     * @param executor Executor address used for redemption.
     */
    event DefaultExecutorSet(address executor);

    /**
     * @notice Emitted when default composer fee is updated.
     * @param defaultComposerFeePPM New default composer fee in PPM.
     */
    event DefaultComposerFeeSet(uint256 defaultComposerFeePPM);

    /**
     * @notice Emitted when srcEid-specific composer fee is set.
     * @param srcEid OFT source endpoint ID.
     * @param composerFeePPM Composer fee in PPM for the specified srcEid.
     */
    event ComposerFeeSet(uint32 indexed srcEid, uint256 composerFeePPM);

    /**
     * @notice Emitted when srcEid-specific composer fee override is removed.
     * @param srcEid OFT source endpoint ID.
     */
    event ComposerFeeRemoved(uint32 indexed srcEid);

    /**
     * @notice Emitted when composer fee recipient is updated.
     * @param composerFeeRecipient New fee recipient address.
     */
    event ComposerFeeRecipientSet(address indexed composerFeeRecipient);

    /**
     * @notice Emitted when composer fee is collected in fAsset.
     * @param guid LayerZero message GUID.
     * @param srcEid Source endpoint ID.
     * @param composerFeeRecipient Recipient of collected composer fee.
     * @param composerFee Collected composer fee amount in fAsset units.
     */
    event ComposerFeeCollected(
        bytes32 indexed guid,
        uint32 indexed srcEid,
        address indexed composerFeeRecipient,
        uint256 composerFee
    );

    /**
     * @notice Reverts when a required address argument is zero.
     */
    error InvalidAddress();

    /**
    * @notice Reverts when the provided executor fee is insufficient for redemption execution.
    */
    error InsufficientExecutorFee(uint256 providedFee, uint256 requiredFee);

    /**
     * @notice Reverts when caller is not the LayerZero endpoint.
     */
    error OnlyEndpoint();

    /**
     * @notice Reverts when compose message source OApp is unexpected.
     * @param from Untrusted source OApp address.
     */
    error InvalidSourceOApp(address from);

    /**
     * @notice Reverts when redeemer account implementation address has no code.
     */
    error InvalidRedeemerAccountImplementation();

    /**
     * @notice Reverts when composer fee PPM is invalid.
     */
    error InvalidComposerFeePPM();

    /**
     * @notice Reverts when composer fee for a srcEid is not set but expected.
     * @param srcEid OFT source endpoint ID.
     */
    error ComposerFeeNotSet(uint32 srcEid);

    /**
     * @notice Reverts when composer fee recipient address is invalid.
     */
    error InvalidComposerFeeRecipient();

    /**
     * @notice Reverts when array lengths do not match.
     */
    error LengthMismatch();

    /**
     * @notice Returns trusted endpoint that may call `lzCompose`.
     * @return Endpoint address.
     */
    function endpoint() external view returns (address);

    /**
     * @notice Returns trusted source OApp.
     * @return Source OApp address.
     */
    function trustedSourceOApp() external view returns (address);

    /**
     * @notice Returns configured asset manager contract.
     * @return Asset manager instance.
     */
    function assetManager() external view returns (IAssetManager);

    /**
     * @notice Returns configured f-asset token.
     * @return F-asset token instance.
     */
    function fAsset() external view returns (IERC20);

    /**
     * @notice Returns configured stable coin used for allowance priming in redeemer accounts.
     * @return Stable coin token.
     */
    function stableCoin() external view returns (IERC20);

    /**
     * @notice Returns configured wrapped native token used for allowance priming in redeemer accounts.
     * @return Wrapped native token.
     */
    function wNat() external view returns (IERC20);

    /**
     * @notice Returns current redeemer account beacon implementation.
     * @return Redeemer account implementation address.
     */
    function redeemerAccountImplementation() external view returns (address);

    /**
     * @notice Returns recipient of collected composer fee.
     * @return Composer fee recipient address.
     */
    function composerFeeRecipient() external view returns (address);

    /**
     * @notice Returns default composer fee in PPM.
     * @return Default composer fee in PPM.
     */
    function defaultComposerFeePPM() external view returns (uint256);

    /**
     * @notice Returns default executor address used for redemption execution.
     * @return Default executor address.
     */
    function defaultExecutor() external view returns (address payable);

    /**
     * @notice Returns composer fee in PPM for the given OFT source endpoint.
     * @param _srcEid OFT source endpoint ID.
     * @return _composerFeePPM Composer fee in PPM.
     */
    function getComposerFeePPM(
        uint32 _srcEid
    )
        external
        view
        returns (uint256 _composerFeePPM);

    /**
     * @notice Returns deterministic redeemer account address for owner.
     * @param _redeemer Redeemer account owner address.
     * @return Deterministic account address.
     */
    function getRedeemerAccountAddress(
        address _redeemer
    )
        external view
        returns (address);

    /**
     * @notice Checks if the given account is the deterministic redeemer account for its owner.
     * @param _address The Flare address to check.
     * @return _isRedeemerAccount True if the address is a redeemer account, false otherwise.
     * @return _owner Redeemer account owner address if it is a redeemer account, zero address otherwise.
     */
    function isRedeemerAccount(
        address _address
    )
        external view
        returns (bool _isRedeemerAccount, address _owner);

    /**
     * @notice Returns the balances of an account for f-asset, stable coin, and wrapped native token.
     * @param _account The address (can be a redeemer account or any other address) for which to retrieve balances.
     * @return _balances The account balances.
     */
    function getBalances(
        address _account
    )
        external view
        returns (AccountBalances memory _balances);
}
