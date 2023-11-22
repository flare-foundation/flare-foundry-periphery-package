// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IFlareContractRegistry} from "../util-contracts/userInterfaces/IFlareContractRegistry.sol";

// Simulates the FlareContractRegistry and can be used in tests

contract FlareContractRegistryMock is IFlareContractRegistry {
    string internal constant ERR_ARRAY_LENGTHS = "array lengths do not match";
    string internal constant ERR_ADDRESS_ZERO = "address zero";

    string[] internal contractNames;
    mapping(bytes32 => address) internal contractAddresses;

    // Check if the newly added contract exists on the real chain
    bool public checkNameValidity = true;

    // Taken directly form the contract registry on the real chain
    string[] public correctContractNames = [
        // AUTO GENERATED - DO NOT EDIT BELOW THIS LINE
        ("FlareDaemon"), ("FtsoRewardManager"), ("Inflation"), ("FtsoManager"), ("ClaimSetupManager"), ("FlareAssetRegistry"), ("VoterWhitelister"), ("StateConnector"), ("PollingFtso"), ("WNat"), ("PollingFoundation"), ("FlareContractRegistry"), ("CleanupBlockNumberManager"), ("FtsoRegistry"), ("GovernanceVotePower"), ("InflationAllocation"), ("GovernanceSettings"), ("Supply"), ("PriceSubmitter"), ("AddressUpdater") 
        //END AUTO GENERATED - DO NOT EDIT ABOVE THIS LINE
    ];

    constructor(bool checkNameValidity_) {
        checkNameValidity = checkNameValidity_;

        contractNames.push("FlareContractRegistry");
        contractAddresses[
            keccak256(abi.encode("FlareContractRegistry"))
        ] = address(this);
    }

    function setCheckNameValidity(bool checkNameValidity_) public {
        checkNameValidity = checkNameValidity_;
    }

    function clear() public {
        for (uint256 i = 0; i < contractNames.length; i++) {
            delete contractAddresses[_keccak256AbiEncode(contractNames[i])];
        }

        delete contractNames;
    }

    /**
     * Add multiple contracts at the same time
     */
    function update(
        string[] memory _contractNames,
        address[] memory _contractAddresses
    ) external {
        _addOrUpdateContractNamesAndAddresses(
            _contractNames,
            _contractAddresses
        );
    }

    /**
     * @notice Add or update contract names and addreses that are later used in updateContractAddresses calls
     * @param _contractNames                contracts names
     * @param _contractAddresses            addresses of corresponding contracts names
     */
    function _addOrUpdateContractNamesAndAddresses(
        string[] memory _contractNames,
        address[] memory _contractAddresses
    ) internal {
        uint256 len = _contractNames.length;
        require(len == _contractAddresses.length, ERR_ARRAY_LENGTHS);
        for (uint256 i = 0; i < len; i++) {
            require(_contractAddresses[i] != address(0), ERR_ADDRESS_ZERO);
            if (checkNameValidity) {
                bool found = false;
                for (uint256 j = 0; j < correctContractNames.length; j++) {
                    if (
                        keccak256(abi.encode(_contractNames[i])) ==
                        keccak256(abi.encode(correctContractNames[j]))
                    ) {
                        found = true;
                        break;
                    }
                }
                require(found, "Invalid contract name");
            }
            bytes32 nameHash = _keccak256AbiEncode(_contractNames[i]);
            // add new contract name if address is not known yet
            if (contractAddresses[nameHash] == address(0)) {
                contractNames.push(_contractNames[i]);
            }
            // set or update contract address
            contractAddresses[nameHash] = _contractAddresses[i];
        }
    }

    /**
     * @notice Returns hash from string value
     */
    function _keccak256AbiEncode(
        string memory _value
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(_value));
    }

    // Real methods

    /// @inheritdoc IFlareContractRegistry
    function getContractAddressByName(
        string calldata _name
    ) external view returns (address) {
        return contractAddresses[_keccak256AbiEncode(_name)];
    }

    /// @inheritdoc IFlareContractRegistry
    function getContractAddressByHash(
        bytes32 _nameHash
    ) external view returns (address) {
        return contractAddresses[_nameHash];
    }

    /// @inheritdoc IFlareContractRegistry
    function getContractAddressesByName(
        string[] calldata _names
    ) external view returns (address[] memory) {
        address[] memory addresses = new address[](_names.length);
        for (uint256 i = 0; i < _names.length; i++) {
            addresses[i] = contractAddresses[_keccak256AbiEncode(_names[i])];
        }
        return addresses;
    }

    /// @inheritdoc IFlareContractRegistry
    function getContractAddressesByHash(
        bytes32[] calldata _nameHashes
    ) external view returns (address[] memory) {
        address[] memory addresses = new address[](_nameHashes.length);
        for (uint256 i = 0; i < _nameHashes.length; i++) {
            addresses[i] = contractAddresses[_nameHashes[i]];
        }
        return addresses;
    }

    /// @inheritdoc IFlareContractRegistry
    function getAllContracts()
        external
        view
        returns (string[] memory _names, address[] memory _addresses)
    {
        _names = contractNames;
        uint256 len = _names.length;
        _addresses = new address[](len);
        while (len > 0) {
            len--;
            _addresses[len] = contractAddresses[
                _keccak256AbiEncode(_names[len])
            ];
        }
    }
}
