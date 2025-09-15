// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

/**
 * Internal interface for contracts that can receive inflation.
 */
interface IIInflationReceiver {
    /**
     * Notify the receiver that it is entitled to receive a new inflation amount.
     * @param _toAuthorizeWei The amount of inflation that can be awarded in the coming day, in wei.
     */
    function setDailyAuthorizedInflation(uint256 _toAuthorizeWei) external;

    /**
     * Receive native tokens from inflation.
     */
    function receiveInflation() external payable;

    /**
     * Returns the address of the `Inflation` contract.
     */
    function getInflationAddress() external returns(address);

    /**
     * Returns the contract's expected balance
     * (actual balance may be higher due to self-destruct funds).
     * @return Expected native token balance.
     */
    function getExpectedBalance() external view returns(uint256);

    /**
     * Implement this function to allow updating inflation receiver contracts through `AddressUpdater`.
     * @return Contract name.
     */
    function getContractName() external view returns (string memory);
}
