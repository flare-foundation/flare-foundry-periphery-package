// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IExecutorsFacet
 * @notice Interface for the ExecutorsFacet contract.
 */
interface IExecutorsFacet {

    /**
     * @notice Emitted when the executor address is set.
     * @param executor The new executor address.
     */
    event ExecutorSet(
        address executor
    );

    /**
     * @notice Emitted when the executor fee is set.
     * @param executorFee The new executor fee.
     */
    event ExecutorFeeSet(
        uint256 executorFee
    );

    /**
     * @notice Reverts if the executor address is invalid.
     */
    error InvalidExecutor();

    /**
     * @notice Reverts if the executor fee is invalid.
     */
    error InvalidExecutorFee();

    /**
     * Returns the executor address and fee.
     * @return _executor The executor address.
     * @return _executorFee The executor fee (in wei).
     */
    function getExecutorInfo()
        external view
        returns (address payable _executor, uint256 _executorFee);
}