// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IPersonalAccount
 * @notice Interface for PersonalAccount contract.
 */
interface IPersonalAccount {
    /**
     * @notice Emitted when collateral is reserved for minting.
     * @param agentVault The agent vault address.
     * @param lots The number of lots that will be minted.
     * @param executor The executor address.
     * @param executorFee The fee paid to the executor.
     * @param collateralReservationId The ID of the collateral reservation.
     */
    event CollateralReserved(
        address agentVault,
        uint256 lots,
        address executor,
        uint256 executorFee,
        uint256 collateralReservationId
    );

    /**
     * @notice Emitted when a transfer of FXRP is made.
     * @param to The recipient address.
     * @param amount The amount of FXRP transferred.
     */
    event FXrpTransferred(
        address to,
        uint256 amount
    );

    /**
     * @notice Emitted when a FXRP redeem operation is performed.
     * @param lots The number of lots redeemed.
     * @param amount The amount redeemed.
     * @param executor The executor address.
     * @param executorFee The fee paid to the executor.
     */
    event FXrpRedeemed(
        uint256 lots,
        uint256 amount,
        address executor,
        uint256 executorFee
    );

    /**
     * @notice Emitted when a token approval is made for a vault.
     * @param fxrp The FXRP token address.
     * @param vault The vault address.
     * @param amount The approved amount.
     */
    event Approved(
        address fxrp,
        address vault,
        uint256 amount
    );

    /**
     * @notice Emitted when a deposit is made to a vault.
     * @param vault The vault address.
     * @param amount The amount deposited.
     * @param shares The number of shares received.
     */
    event Deposited(
        address indexed vault,
        uint256 amount,
        uint256 shares
    );

    /**
     * @notice Emitted when a redeem is made from a vault.
     * @param vault The vault address.
     * @param amount The amount redeemed.
     * @param shares The number of shares burned.
     */
    event Redeemed(
        address indexed vault,
        uint256 amount,
        uint256 shares
    );

    /**
     * @notice Emitted when a withdrawal claim is made.
     * @param vault The vault address.
     * @param period The period for which the claim is made.
     * @param amount The amount claimed.
     */
    event WithdrawalClaimed(
        address indexed vault,
        uint256 period,
        uint256 amount
    );

    /**
     * @notice Emitted when a redeem request is made.
     * @param vault The vault address.
     * @param shares The number of shares to redeem.
     * @param claimableEpoch The epoch when the claim becomes available.
     * @param year The year of the claimable date.
     * @param month The month of the claimable date.
     * @param day The day of the claimable date.
     */
    event RedeemRequested(
        address indexed vault,
        uint256 shares,
        uint256 claimableEpoch,
        uint256 year,
        uint256 month,
        uint256 day
    );

    /**
     * @notice Emitted when a claim is made for a specific date.
     * @param vault The vault address.
     * @param year The year of the claim.
     * @param month The month of the claim.
     * @param day The day of the claim.
     * @param shares The number of shares claimed.
     * @param amount The amount claimed.
     */
    event Claimed(
        address indexed vault,
        uint256 year,
        uint256 month,
        uint256 day,
        uint256 shares,
        uint256 amount
    );

    /**
     * @notice Emitted when a token swap is executed.
     * @param tokenIn The input token address.
     * @param tokenOut The output token address.
     * @param amountIn The amount of input tokens.
     * @param amountOut The amount of output tokens received.
     */
    event SwapExecuted(
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Reverts if the sent value is insufficient for collateral reservation.
     * @param collateralReservationFee The required collateral reservation fee.
     * @param executorFee The required executor fee.
     */
    error InsufficientFundsForCollateralReservation(
        uint256 collateralReservationFee,
        uint256 executorFee
    );

    /**
     * @notice Reverts if the sent value is insufficient for redeem operation.
     * @param executorFee The required executor fee.
     */
    error InsufficientFundsForRedeem(
        uint256 executorFee
    );

    /**
     * @notice Reverts if the caller is not the controller.
     */
    error OnlyController();

    /**
     * @notice Reverts if the contract is already initialized.
     */
    error AlreadyInitialized();

    /**
     * @notice Reverts if the controller address is invalid.
     */
    error InvalidControllerAddress();

    /**
     * @notice Reverts if the XRPL owner address is invalid.
     */
    error InvalidXrplOwner();

    /**
     * @notice Reverts if the agent is not available.
     */
    error AgentNotAvailable();

    /**
     * @notice Reverts if the token approval fails.
     */
    error ApprovalFailed();

    /**
     * @notice Returns the XRPL owner address associated with this personal account.
     * @return The XRPL owner address
     */
    function xrplOwner() external view returns (string memory);

    /**
     * @notice Returns the controller address that manages this personal account.
     * @return The controller address
     */
    function controllerAddress() external view returns (address);

    /**
     * @notice Returns implementation address of the personal account.
     * @return The implementation address
     */
    function implementation() external view returns (address);
}
