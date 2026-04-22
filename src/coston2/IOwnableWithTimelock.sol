// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IOwnableWithTimelock
 * @notice Generic interface for ownable timelocked call execution.
 */
interface IOwnableWithTimelock {

    /**
     * @notice Emitted when a call is timelocked and can be executed later.
     * @param encodedCall ABI encoded call data.
     * @param encodedCallHash Hash of encoded call.
     * @param allowedAfterTimestamp Earliest timestamp when call is executable.
     */
    event CallTimelocked(bytes encodedCall, bytes32 encodedCallHash, uint256 allowedAfterTimestamp);

    /**
     * @notice Emitted when a timelocked call is executed.
     * @param encodedCallHash Hash of encoded call.
     */
    event TimelockedCallExecuted(bytes32 encodedCallHash);

    /**
     * @notice Emitted when a timelocked call is canceled.
     * @param encodedCallHash Hash of encoded call.
     */
    event TimelockedCallCanceled(bytes32 encodedCallHash);

    /**
     * @notice Emitted when timelock duration is updated.
     * @param timelockDurationSeconds New timelock duration in seconds.
     */
    event TimelockDurationSet(uint256 timelockDurationSeconds);

    /**
     * @notice Reverts when timelocked call selector is invalid.
     */
    error TimelockInvalidSelector();

    /**
     * @notice Reverts when timelocked call execution is attempted too early.
     */
    error TimelockNotAllowedYet();

    /**
     * @notice Reverts when requested timelock duration exceeds maximum.
     */
    error TimelockDurationTooLong();

    /**
     * @notice Executes a previously timelocked call after delay has passed.
     * @param _encodedCall ABI encoded call data.
     * @dev Can be executed by anyone after the timelock duration has passed.
     */
    function executeTimelockedCall(bytes calldata _encodedCall) external;

    /**
     * @notice Cancels a queued timelocked call.
     * @param _encodedCall ABI encoded call data.
     */
    function cancelTimelockedCall(bytes calldata _encodedCall) external;

    /**
     * @notice Sets timelock duration for owner-controlled calls.
     * @param _timelockDurationSeconds Timelock duration in seconds.
     */
    function setTimelockDuration(uint256 _timelockDurationSeconds) external;

    /**
     * @notice Returns timestamp when a timelocked call may be executed.
     * @param _encodedCall ABI encoded call data.
     * @return _allowedAfterTimestamp Earliest execution timestamp.
     */
    function getExecuteTimelockedCallTimestamp(
        bytes calldata _encodedCall
    )
        external view
        returns (uint256 _allowedAfterTimestamp);

    /**
     * @notice Returns the configured timelock duration in seconds.
     * @return Timelock duration in seconds.
     */
    function getTimelockDurationSeconds() external view returns (uint256);
}
