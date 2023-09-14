// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {IFtso} from "../../coston2/ftso/userInterfaces/IFtso.sol";
import {IPriceSubmitter} from "../../coston2/ftso/userInterfaces/IPriceSubmitter.sol";
import {IFtsoRegistry} from "../../coston2/ftso/userInterfaces/IFtsoRegistry.sol";

contract SimpleFtsoExample {
    function getPriceSubmitter() public view virtual returns (IPriceSubmitter) {
        return IPriceSubmitter(0x1000000000000000000000000000000000000003);
    }

    function getTokenPriceWei(
        string memory foreignTokenSymbol
    )
        public
        view
        returns (uint256 _price, uint256 _timestamp, uint256 _decimals)
    {
        IFtsoRegistry ftsoRegistry = IFtsoRegistry(
            address(getPriceSubmitter().getFtsoRegistry())
        );
        (_price, _timestamp, _decimals) = ftsoRegistry
            .getCurrentPriceWithDecimals(foreignTokenSymbol);
    }
}
