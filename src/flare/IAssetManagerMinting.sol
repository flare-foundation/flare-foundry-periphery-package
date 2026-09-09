// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import {IPayment} from ".//IPayment.sol";
import {IReferencedPaymentNonexistence} from ".//IReferencedPaymentNonexistence.sol";
import {IConfirmedBlockHeightExists} from ".//IConfirmedBlockHeightExists.sol";
import {CollateralReservationInfo} from "./data/CollateralReservationInfo.sol";

/**
 * Periphery-defined view of IAssetManager.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IAssetManagerMinting {
    /**
     * Before paying underlying assets for minting, minter has to reserve collateral and
     * pay collateral reservation fee. Collateral is reserved at ratio of agent's agentMinCollateralRatio
     * to requested lots NAT market price.
     * The minter receives instructions for underlying payment
     * (value, fee and payment reference) in event CollateralReserved.
     * Then the minter has to pay `value + fee` on the underlying chain.
     * If the minter pays the underlying amount, minter obtains f-assets.
     * The collateral reservation fee is split between the agent and the collateral pool.
     * NOTE: the owner of the agent vault must be in the AgentOwnerRegistry.
     * NOTE: if the underlying block isn't updated regularly, it can happen that there is not enough time for
     * the underlying payment. Therefore minters have to verify the current underlying before minting and,
     * if needed, update it by calling `updateCurrentBlock`.
     * @param _agentVault agent vault address
     * @param _lots the number of lots for which to reserve collateral
     * @param _maxMintingFeeBIPS maximum minting fee (BIPS) that can be charged by the agent - best is just to
     *      copy current agent's published fee; used to prevent agent from front-running reservation request
     *      and increasing fee (that would mean that the minter would have to pay raised fee or forfeit
     *      collateral reservation fee)
     * @param _executor the account that is allowed to execute minting (besides minter and agent)
     */
    function reserveCollateral(
        address _agentVault,
        uint256 _lots,
        uint256 _maxMintingFeeBIPS,
        address payable _executor
    ) external payable
        returns (uint256 _collateralReservationId);

    /**
     * Return the collateral reservation fee amount that has to be passed to the `reserveCollateral` method.
     * NOTE: the amount paid may be larger than the required amount, but the difference is not returned.
     * It is advised that the minter pays the exact amount, but when the amount is so small that the revert
     * would cost more than the lost difference, the minter may want to send a slightly larger amount to compensate
     * for the possibility of a FTSO price change between obtaining this value and calling `reserveCollateral`.
     * @param _lots the number of lots for which to reserve collateral
     * @return _reservationFeeNATWei the amount of reservation fee in NAT wei
     */
    function collateralReservationFee(uint256 _lots)
        external view
        returns (uint256 _reservationFeeNATWei);

    /**
     * Returns the data about the collateral reservation for an ongoing minting.
     * Note: once the minting is executed or defaulted, the collateral reservation is deleted and this method fails.
     * @param _collateralReservationId the collateral reservation id, as used for executing or defaulting the minting
     */
    function collateralReservationInfo(uint256 _collateralReservationId)
        external view
        returns (CollateralReservationInfo.Data memory);

    /**
     * After obtaining proof of underlying payment, the minter calls this method to finish the minting
     * and collect the minted f-assets.
     * NOTE: may only be called by the minter (= creator of CR, the collateral reservation request),
     *   the executor appointed by the minter, or the agent owner (= owner of the agent vault in CR).
     * @param _payment proof of the underlying payment (must contain exact `value + fee` amount and correct
     *      payment reference)
     * @param _collateralReservationId collateral reservation id
     */
    function executeMinting(
        IPayment.Proof calldata _payment,
        uint256 _collateralReservationId
    ) external;

    /**
     * When the time for the minter to pay the underlying amount is over (i.e. the last underlying block has passed),
     * the agent can declare payment default. Then the agent collects the collateral reservation fee
     * (it goes directly to the vault), and the reserved collateral is unlocked.
     * NOTE: The attestation request must be done with `checkSourceAddresses=false`.
     * NOTE: may only be called by the owner of the agent vault in the collateral reservation request.
     * @param _proof proof that the minter didn't pay with correct payment reference on the underlying chain
     * @param _collateralReservationId id of a collateral reservation created by the minter
     */
    function mintingPaymentDefault(
        IReferencedPaymentNonexistence.Proof calldata _proof,
        uint256 _collateralReservationId
    ) external;

    /**
     * The minter can make several mistakes in the underlying payment:
     * - the payment is too late and is already defaulted before executing
     * - the payment is too small so executeMinting reverts
     * - the payment is performed twice
     * In all of these cases the paid amount ends up on the agent vault's underlying account, but it is not
     * confirmed and therefore the agent cannot withdraw it without triggering full liquidation (of course
     * the agent can legally withdraw it once the vault is closed).
     * This method enables the agent to confirm such payments, converting the deposited amount to agent's
     * free underlying.
     * NOTE: may only be called by the agent vault owner.
     * @param _payment proof of the underlying payment (must have correct payment reference)
     * @param _collateralReservationId collateral reservation id
     */
    function confirmClosedMintingPayment(
        IPayment.Proof calldata _payment,
        uint256 _collateralReservationId
    ) external;

    /**
     * If a collateral reservation request exists for more than 24 hours, payment or non-payment proof are no longer
     * available. In this case the agent can call this method, which burns reserved collateral at market price
     * and releases the remaining collateral (CRF is also burned).
     * NOTE: may only be called by the owner of the agent vault in the collateral reservation request.
     * NOTE: the agent (management address) receives the vault collateral and NAT is burned instead. Therefore
     *      this method is `payable` and the caller must provide enough NAT to cover the received vault collateral
     *      amount multiplied by `vaultCollateralBuyForFlareFactorBIPS`.
     * @param _proof proof that the attestation query window can not not contain
     *      the payment/non-payment proof anymore
     * @param _collateralReservationId collateral reservation id
     */
    function unstickMinting(
        IConfirmedBlockHeightExists.Proof calldata _proof,
        uint256 _collateralReservationId
    ) external payable;

    /**
     * Agent can mint against himself.
     * This is a one-step process, skipping collateral reservation and collateral reservation fee payment.
     * Moreover, the agent doesn't have to be on the publicly available agents list to self-mint.
     * NOTE: may only be called by the agent vault owner.
     * NOTE: the caller must be a whitelisted agent.
     * @param _payment proof of the underlying payment; must contain payment reference of the form
     *      `0x4642505266410012000...0<agent_vault_address>`
     * @param _agentVault agent vault address
     * @param _lots number of lots to mint
     */
    function selfMint(
        IPayment.Proof calldata _payment,
        address _agentVault,
        uint256 _lots
    ) external;

    /**
     * If an agent has enough free underlying, they can mint immediately without any underlying payment.
     * This is a one-step process, skipping collateral reservation and collateral reservation fee payment.
     * Moreover, the agent doesn't have to be on the publicly available agents list to self-mint.
     * NOTE: may only be called by the agent vault owner.
     * NOTE: the caller must be a whitelisted agent.
     * @param _agentVault agent vault address
     * @param _lots number of lots to mint
     */
    function mintFromFreeUnderlying(
        address _agentVault,
        uint64 _lots
    ) external;

    /**
     * Minter reserved collateral, paid the reservation fee, and is expected to pay the underlying funds.
     * Agent's collateral was reserved.
     */
    event CollateralReserved(
        address indexed agentVault,
        address indexed minter,
        uint256 indexed collateralReservationId,
        uint256 valueUBA,
        uint256 feeUBA,
        uint256 firstUnderlyingBlock,
        uint256 lastUnderlyingBlock,
        uint256 lastUnderlyingTimestamp,
        string paymentAddress,
        bytes32 paymentReference,
        address executor,
        uint256 executorFeeNatWei);

    /**
     * Minter paid underlying funds in time and received the fassets.
     * The agent's collateral is locked.
     */
    event MintingExecuted(
        address indexed agentVault,
        uint256 indexed collateralReservationId,
        uint256 mintedAmountUBA,
        uint256 agentFeeUBA,
        uint256 poolFeeUBA);

    /**
     * Minter failed to pay underlying funds in time. Collateral reservation fee was paid to the agent.
     * Reserved collateral was released.
     */
    event MintingPaymentDefault(
        address indexed agentVault,
        address indexed minter,
        uint256 indexed collateralReservationId,
        uint256 reservedAmountUBA);

    /**
     * Both minter and agent failed to present any proof within attestation time window, so
     * the agent called `unstickMinting` to release reserved collateral.
     */
    event CollateralReservationDeleted(
        address indexed agentVault,
        address indexed minter,
        uint256 indexed collateralReservationId,
        uint256 reservedAmountUBA);

    /**
     * Emitted when a late or too small payment for an already defaulted or expired minting is confirmed.
     * It is equivalent to agent performing underlying topup.
     */
    event ConfirmedClosedMintingPayment(
        address indexed agentVault,
        bytes32 transactionHash,
        uint256 depositedUBA);

    /**
     * Agent performed self minting, either by executing selfMint with underlying deposit or
     * by executing mintFromFreeUnderlying (in this case, `mintFromFreeUnderlying` is true and
     * `depositedAmountUBA` is zero).
     */
    event SelfMint(
        address indexed agentVault,
        bool mintFromFreeUnderlying,
        uint256 mintedAmountUBA,
        uint256 depositedAmountUBA,
        uint256 poolFeeUBA);
}
