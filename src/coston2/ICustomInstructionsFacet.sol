// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title ICustomInstructionsFacet
 * @notice Interface for the CustomInstructionsFacet contract.
 */
interface ICustomInstructionsFacet {

    /// @notice Struct containing custom call information
    struct CustomCall {
        /// @notice Target contract address
        address targetContract;
        /// @notice value (in wei) to send with the call
        uint256 value;
        /// @notice Call data
        bytes data;
    }

    /**
     * @notice Emitted when a custom instruction is registered.
     * @param customInstructionHash The hash representing the registered instructions.
     */
    event CustomInstructionRegistered(bytes32 indexed customInstructionHash);

    /**
     * @notice Emitted when a custom instruction is already registered.
     * @param customInstructionHash The hash representing the already registered instructions.
     */
    event CustomInstructionAlreadyRegistered(bytes32 indexed customInstructionHash);

    /**
     * @notice Reverts if the custom instruction is empty (zero custom calls).
     */
    error EmptyCustomInstruction();

    /**
     * @notice Reverts if the target address of a custom call is zero.
     */
    error TargetAddressZero();

    /**
     * @notice Reverts if the target address of a custom call is not a contract.
     * @param target The target address.
     */
    error TargetNotAContract(address target);

    /**
     * @notice Register custom instruction and return the call hash.
     * @param _customInstruction Custom instruction (array of custom calls) to register.
     * @return _customInstructionHash The hash representing the registered custom instruction.
     */
    function registerCustomInstruction(
        CustomCall[] memory _customInstruction
    ) external returns (bytes32 _customInstructionHash);

    /**
     * @notice Get a custom instruction for a given call hash.
     * @param _customInstructionHash The hash representing the custom instruction.
     * @return _customInstruction Custom instruction (array of custom calls) for the hash.
     */
    function getCustomInstruction(
        bytes32 _customInstructionHash
    ) external view returns (CustomCall[] memory _customInstruction);
    /**
     * @notice Get paginated custom instruction hashes.
     * @param _start The starting index.
     * @param _end The ending index.
     * @return _customInstructionHashes Array of custom instruction hashes for the requested page.
     * @return _totalLength The total number of custom instruction hashes.
     */
    function getCustomInstructionHashes(
        uint256 _start,
        uint256 _end
    ) external view returns (bytes32[] memory _customInstructionHashes, uint256 _totalLength);

    /**
     * @notice Encode a custom instruction to get its call hash.
     * @param _customInstruction Custom instruction (array of custom calls) to encode.
     * @return _customInstructionHash The hash representing the custom instruction.
     */
    function encodeCustomInstruction(
        CustomCall[] memory _customInstruction
    ) external pure returns (bytes32 _customInstructionHash);
}
