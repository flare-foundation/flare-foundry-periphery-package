// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title ITimelockFacet
 * @notice Interface for the TimelockFacet contract.
 */
interface ITimelockFacet {

    /**
     * @notice Emitted when a call is timelocked. It can be executed after the `allowedAfterTimestamp` timestamp.
     * @param encodedCall The ABI encoded call data, to be used in `executeTimelockedCall`.
     * @param encodedCallHash The hash of the encoded call data.
     * @param allowedAfterTimestamp The earliest timestamp when the call can be executed.
     */
    event CallTimelocked(
        bytes encodedCall,
        bytes32 encodedCallHash,
        uint256 allowedAfterTimestamp
    );

    /**
     * @notice Emitted when a timelocked call is executed.
     * @param encodedCallHash The hash of the encoded call data.
     */
    event TimelockedCallExecuted(
        bytes32 encodedCallHash
    );

    /**
     * @notice Emitted when a timelocked call is canceled.
     * @param encodedCallHash The hash of the encoded call data.
     */
    event TimelockedCallCanceled(
        bytes32 encodedCallHash
    );

    /**
     * @notice Emitted when the timelock duration is set.
     * @param timelockDurationSeconds The new timelock duration in seconds.
     */
    event TimelockDurationSet(
        uint256 timelockDurationSeconds
    );

    /**
     * @notice Reverts if the timelocked call selector is invalid.
     */
    error TimelockInvalidSelector();

    /**
     * @notice Reverts if the timelock period has not yet expired.
     */
    error TimelockNotAllowedYet();

    /**
     * @notice Reverts if the timelock duration is too long.
     */
    error TimelockDurationTooLong();

    /**
     * @notice Execute a timelocked call once the timelock period expires.
     * @dev Anyone can call this method.
     * @param _encodedCall ABI encoded call data (signature and parameters).
     */
    function executeTimelockedCall(
        bytes calldata _encodedCall
    )
        external;

    /**
     * @notice Returns the timestamp after which the timelocked call can be executed.
     * @param _encodedCall ABI encoded call data (signature and parameters).
     * @return _allowedAfterTimestamp The timestamp after which the call can be executed.
     */
    function getExecuteTimelockedCallTimestamp(
        bytes calldata _encodedCall
    )
        external view
        returns (uint256 _allowedAfterTimestamp);

    /**
     * Returns the timelock duration in seconds.
     * @return _timelockDurationSeconds The timelock duration in seconds.
     */
    function getTimelockDurationSeconds()
        external view
        returns (uint256 _timelockDurationSeconds);
}