// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title IInstructionFeesFacet
 * @notice Interface for the InstructionFeesFacet contract.
 */
interface IInstructionFeesFacet {

    /**
     * @notice Emitted when the default instruction fee is set.
     * @param defaultInstructionFee The new default instruction fee.
     */
    event DefaultInstructionFeeSet(
        uint256 defaultInstructionFee
    );

    /**
     * @notice Emitted when an instruction-specific fee is set.
     * @param instructionId The instruction ID.
     * @param instructionFee The fee for the instruction.
     */
    event InstructionFeeSet(
        uint256 indexed instructionId,
        uint256 instructionFee
    );

    /**
     * @notice Emitted when an instruction-specific fee is removed.
     * @param instructionId The instruction ID.
     */
    event InstructionFeeRemoved(
        uint256 indexed instructionId
    );

    /**
     * @notice Reverts if array lengths do not match.
     */
    error InstructionFeesLengthsMismatch();

    /**
     * @notice Reverts if the instruction fee is invalid.
     * @param instructionId The instruction ID.
     */
    error InvalidInstructionFee(
        uint256 instructionId
    );

    /**
     * @notice Reverts if the instruction fee is not set.
     * @param instructionId The instruction ID.
     */
    error InstructionFeeNotSet(
        uint256 instructionId
    );

    /**
     * @notice Returns the default instruction fee.
     * @return The default instruction fee in underlying asset's smallest unit (e.g., drops for XRP).
     */
    function getDefaultInstructionFee()
        external view
        returns (uint256);

    /**
     * @notice Returns the instruction fee for a given instruction ID.
     * @param _instructionId The ID of the instruction.
     * @return The instruction fee in underlying asset's smallest unit (e.g., drops for XRP).
     */
    function getInstructionFee(
        uint256 _instructionId
    )
        external view
        returns (uint256);

}