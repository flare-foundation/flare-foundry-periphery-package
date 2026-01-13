// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4 <0.9;

/**
 * @title ISwapFacet
 * @notice Interface for the SwapFacet contract.
 */
interface ISwapFacet {

    /**
     * @notice Emitted when swap parameters are set.
     * @param uniswapV3Router The Uniswap V3 router address.
     * @param usdt0 USDT0 token address.
     * @param wNatUsdt0PoolFeeTierPPM The WNAT/USDT0 pool fee tier (in PPM - supported values: 100, 500, 3000, 10000).
     * @param usdt0FXrpPoolFeeTierPPM The USDT0/FXRP pool fee tier (in PPM - supported values: 100, 500, 3000, 10000).
     * @param maxSlippagePPM The maximum slippage allowed for swaps (in PPM).
     */
    event SwapParamsSet(
        address uniswapV3Router,
        address usdt0,
        uint24 wNatUsdt0PoolFeeTierPPM,
        uint24 usdt0FXrpPoolFeeTierPPM,
        uint24 maxSlippagePPM
    );

    /**
     * @notice Emitted when a token swap is executed.
     * @param personalAccount The personal account address.
     * @param tokenIn The input token address.
     * @param tokenOut The output token address.
     * @param xrplOwner The XRPL owner address.
     * @param amountIn The amount of input tokens.
     * @param amountOut The amount of output tokens received.
     */
    event SwapExecuted(
        address indexed personalAccount,
        address indexed tokenIn,
        address indexed tokenOut,
        string xrplOwner,
        uint256 amountIn,
        uint256 amountOut
    );

    /**
     * @notice Reverts if the Uniswap V3 router address is invalid.
     */
    error InvalidUniswapV3Router();

    /**
     * @notice Reverts if the pool fee tier in PPM is invalid (allowed values: 100, 500, 3000, 10000).
     */
    error InvalidPoolFeeTierPPM();

    /**
     * @notice Reverts if the USDT0 token address is invalid.
     */
    error InvalidUsdt0();

    /**
     * @notice Reverts if the maximum slippage in PPM is invalid (must be less than or equal to 1e6).
     */
    error InvalidMaxSlippagePPM();

    /**
     * @notice Swaps WNAT for USDT0 for the personal account associated with the given XRPL address.
     * @param _xrplAddress The XRPL address of the personal account.
     */
    function swapWNatForUsdt0(
        string calldata _xrplAddress
    )
        external;

    /**
     * @notice Swaps USDT0 for FAsset for the personal account associated with the given XRPL address.
     * @param _xrplAddress The XRPL address of the personal account.
     */
    function swapUsdt0ForFAsset(
        string calldata _xrplAddress
    )
        external;

    /**
     * Returns the swap parameters.
     * @return _uniswapV3Router The Uniswap V3 router address.
     * @return _usdt0 USDT0 token address.
     * @return _wNatUsdt0PoolFeeTierPPM The WNAT/USDT0 pool fee tier (in PPM).
     * @return _usdt0FXrpPoolFeeTierPPM The USDT0/FXRP pool fee tier (in PPM).
     * @return _maxSlippagePPM The maximum slippage allowed for swaps (in PPM).
     */
    function getSwapParams()
        external view
        returns (
            address _uniswapV3Router,
            address _usdt0,
            uint24 _wNatUsdt0PoolFeeTierPPM,
            uint24 _usdt0FXrpPoolFeeTierPPM,
            uint24 _maxSlippagePPM
        );
}