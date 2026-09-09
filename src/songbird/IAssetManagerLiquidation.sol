// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import {IBalanceDecreasingTransaction} from ".//IBalanceDecreasingTransaction.sol";

/**
 * Periphery-defined view of IAssetManager.
 * Pass the diamond address; not a separate deployed contract.
 */
interface IAssetManagerLiquidation {
    /**
     * Checks that the agent's collateral is too low and if true, starts agent's liquidation.
     * If the agent is already in liquidation, returns the timestamp when liquidation started.
     * @param _agentVault agent vault address
     * @return _liquidationStartTs timestamp when liquidation started
     */
    function startLiquidation(
        address _agentVault
    ) external
        returns (uint256 _liquidationStartTs);

    /**
     * Burns up to `_amountUBA` f-assets owned by the caller and pays
     * the caller the corresponding amount of native currency with premium
     * (premium depends on the liquidation state).
     * If the agent isn't in liquidation yet, but satisfies conditions,
     * automatically puts the agent in liquidation status.
     * @param _agentVault agent vault address
     * @param _amountUBA the amount of f-assets to liquidate
     * @return _liquidatedAmountUBA liquidated amount of f-asset
     * @return _amountPaidVault amount paid to liquidator (in agent's vault collateral)
     * @return _amountPaidPool amount paid to liquidator (in NAT from pool)
     */
    function liquidate(
        address _agentVault,
        uint256 _amountUBA
    ) external
        returns (uint256 _liquidatedAmountUBA, uint256 _amountPaidVault, uint256 _amountPaidPool);

    /**
     * When the agent's collateral reaches the safe level during liquidation, the liquidation
     * process can be stopped by calling this method.
     * Full liquidation (i.e. the liquidation triggered by illegal underlying payment)
     * cannot be stopped.
     * NOTE: anybody can call.
     * NOTE: if the method succeeds, the agent's liquidation has ended.
     * @param _agentVault agent vault address
     */
    function endLiquidation(
        address _agentVault
    ) external;

    /**
     * Called with a proof of payment made from the agent's underlying address, for which
     * no valid payment reference exists (valid payment references are from redemption and
     * underlying withdrawal announcement calls).
     * On success, immediately triggers full agent liquidation and rewards the caller.
     * @param _payment proof of a transaction from the agent's underlying address
     * @param _agentVault agent vault address
     */
    function illegalPaymentChallenge(
        IBalanceDecreasingTransaction.Proof calldata _payment,
        address _agentVault
    ) external;

    /**
     * Called with proofs of two payments made from the agent's underlying address
     * with the same payment reference (each payment reference is valid for only one payment).
     * On success, immediately triggers full agent liquidation and rewards the caller.
     * @param _payment1 proof of first payment from the agent's underlying address
     * @param _payment2 proof of second payment from the agent's underlying address
     * @param _agentVault agent vault address
     */
    function doublePaymentChallenge(
        IBalanceDecreasingTransaction.Proof calldata _payment1,
        IBalanceDecreasingTransaction.Proof calldata _payment2,
        address _agentVault
    ) external;

    /**
     * Called with proofs of several (otherwise legal) payments, which together make the agent's
     * underlying free balance negative (i.e. the underlying address balance is less than
     * the total amount of backed f-assets).
     * On success, immediately triggers full agent liquidation and rewards the caller.
     * @param _payments proofs of several distinct payments from the agent's underlying address
     * @param _agentVault agent vault address
     */
    function freeBalanceNegativeChallenge(
        IBalanceDecreasingTransaction.Proof[] calldata _payments,
        address _agentVault
    ) external;

    /**
     * Agent entered liquidation state due to unhealthy position.
     * The liquidation ends when the agent is again healthy or the agent's position is fully liquidated.
     */
    event LiquidationStarted(
        address indexed agentVault,
        uint256 timestamp);

    /**
     * Agent entered liquidation state due to illegal payment.
     * Full liquidation will always liquidate the whole agent's position and
     * the agent can never use the same vault and underlying address for minting again.
     */
    event FullLiquidationStarted(
        address indexed agentVault,
        uint256 timestamp);

    /**
     * Some of the agent's position was liquidated, by burning liquidator's fassets.
     * Liquidator was paid in collateral with extra.
     * The corresponding amount of underlying currency, held by the agent, is released
     * and the agent can withdraw it (after underlying withdrawal announcement).
     */
    event LiquidationPerformed(
        address indexed agentVault,
        address indexed liquidator,
        uint256 valueUBA,
        uint256 paidVaultCollateralWei,
        uint256 paidPoolCollateralWei);

    /**
     * Agent exited liquidation state as agent's position was healthy again and not in full liquidation.
     */
    event LiquidationEnded(
        address indexed agentVault);

    /**
     * An unexpected transaction from the agent's underlying address was proved.
     * Whole agent's position goes into liquidation.
     * The challenger is rewarded from the agent's collateral.
     */
    event IllegalPaymentConfirmed(
        address indexed agentVault,
        bytes32 transactionHash);

    /**
     * Two transactions with the same payment reference, both from the agent's underlying address, were proved.
     * Whole agent's position goes into liquidation.
     * The challenger is rewarded from the agent's collateral.
     */
    event DuplicatePaymentConfirmed(
        address indexed agentVault,
        bytes32 transactionHash1,
        bytes32 transactionHash2);

    /**
     * Agent's underlying balance became lower than required for backing f-assets (either through payment or via
     * a challenge. Agent goes to a full liquidation.
     * The challenger is rewarded from the agent's collateral.
     */
    event UnderlyingBalanceTooLow(
        address indexed agentVault,
        int256 balance,
        uint256 requiredBalance);
}
