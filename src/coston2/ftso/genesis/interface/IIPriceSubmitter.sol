// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6 <0.9;

import "../../userInterfaces/IPriceSubmitter.sol";
interface IIPriceSubmitter is IPriceSubmitter {

    /**
     * Set trusted addresses that are always allowed to submit and reveal.
     * Only ftso manager can call this method.
     */
    function setTrustedAddresses(address[] memory _trustedAddresses) external;

    /**
     * Called from whitelister when new voter has been whitelisted.
     */
    function voterWhitelisted(address _voter, uint256 _ftsoIndex) external;
    
    /**
     * Called from whitelister when one or more voters have been removed.
     */
    function votersRemovedFromWhitelist(address[] memory _voters, uint256 _ftsoIndex) external;

    /**
     * Returns a list of trusted addresses that are always allowed to submit and reveal.
     */
    function getTrustedAddresses() external view returns (address[] memory);
}
