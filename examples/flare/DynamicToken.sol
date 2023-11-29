// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import {IERC20Metadata} from "openzeppelin-contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IFtso} from "../../flare/ftso/userInterfaces/IFtso.sol";
import {IPriceSubmitter} from "../../flare/ftso/userInterfaces/IPriceSubmitter.sol";
import {IFtsoRegistry} from "../../flare/ftso/userInterfaces/IFtsoRegistry.sol";

error InsufficientBalance(uint256 available, uint256 required);
error OnylOwner();
error SupplyCeiling();

contract DynamicToken is IERC20Metadata {
    string public override name;
    string public override symbol;
    uint8 public override decimals;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    address public immutable owner;

    string public nativeTokenSymbol;
    string public foreignTokenSymbol;
    uint256 public tokensPerForeignToken;

    uint256 public immutable maxSupply;
    uint256 public override totalSupply;

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OnylOwner();
        }
        _;
    }

    constructor(
        uint256 _maxSupply,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        string memory _nativeTokenSymbol,
        string memory _foreignTokenSymbol,
        uint256 _tokensPerForeignToken
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        maxSupply = _maxSupply;
        owner = msg.sender;
        nativeTokenSymbol = _nativeTokenSymbol;
        foreignTokenSymbol = _foreignTokenSymbol;
        tokensPerForeignToken = _tokensPerForeignToken;
    }

    function getPriceSubmitter() public view virtual returns (IPriceSubmitter) {
        return IPriceSubmitter(0x1000000000000000000000000000000000000003);
    }

    function balanceOf(
        address account
    ) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(
        address to,
        uint256 amount
    ) external override returns (bool) {
        if (amount > _balances[msg.sender]) {
            revert InsufficientBalance(_balances[msg.sender], amount);
        }

        _balances[msg.sender] -= amount;
        _balances[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function allowance(
        address _owner,
        address spender
    ) external view override returns (uint256) {
        return _allowances[_owner][spender];
    }

    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external override returns (bool) {
        if (amount > _balances[from]) {
            revert InsufficientBalance(_balances[from], amount);
        }

        if (amount > _allowances[from][msg.sender]) {
            revert InsufficientBalance(_allowances[from][msg.sender], amount);
        }

        _balances[from] -= amount;
        _balances[to] += amount;
        _allowances[from][msg.sender] -= amount;
        emit Transfer(from, to, amount);
        return true;
    }

    function getTokenPriceWei() public view returns (uint256 natWeiPerToken) {
        IFtsoRegistry ftsoRegistry = IFtsoRegistry(
            address(getPriceSubmitter().getFtsoRegistry())
        );
        (uint256 foreignTokenToUsd, ) = ftsoRegistry.getCurrentPrice(
            foreignTokenSymbol
        );
        uint256 foreignTokenFTSODecimals = 5;
        (uint256 nativeToUsd, ) = ftsoRegistry.getCurrentPrice(
            nativeTokenSymbol
        );
        uint256 nativeTokenFTSODecimals = 5;
        natWeiPerToken =
            ((10 ** 18) * foreignTokenToUsd * (10 ** nativeTokenFTSODecimals)) /
            (nativeToUsd *
                tokensPerForeignToken *
                (10 ** decimals) *
                (10 ** foreignTokenFTSODecimals));
    }

    function _mint() private returns (uint256 tokenAmount) {
        uint256 price = getTokenPriceWei();

        tokenAmount = msg.value / price;
        uint256 remainder = msg.value - tokenAmount * price;

        if (totalSupply + tokenAmount > maxSupply) {
            revert SupplyCeiling();
        }

        _balances[msg.sender] += tokenAmount;
        totalSupply += tokenAmount;

        payable(msg.sender).transfer(remainder);

        emit Transfer(address(0), msg.sender, tokenAmount);
    }

    function mint() external payable returns (uint256) {
        return _mint();
    }

    // Forward everything to deposit
    receive() external payable {
        _mint();
    }

    fallback() external payable {
        _mint();
    }

    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
