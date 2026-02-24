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
     * @param stableCoin StableCoin (USDT0, USDX,...) token address.
     * @param wNatStableCoinPoolFeeTierPPM The WNAT/StableCoin pool fee tier
              (in PPM - supported values: 100, 500, 3000, 10000).
     * @param stableCoinFXrpPoolFeeTierPPM The StableCoin/FXRP pool fee tier
              (in PPM - supported values: 100, 500, 3000, 10000).
     * @param maxSlippagePPM The maximum slippage allowed for swaps (in PPM).
     * @param stableCoinUsdFeedId The StableCoin/USD feed ID as in FTSO.
     * @param wNatUsdFeedId The WNAT/USD feed ID as in FTSO.
     */
    event SwapParamsSet(
        address uniswapV3Router,
        address stableCoin,
        uint24 wNatStableCoinPoolFeeTierPPM,
        uint24 stableCoinFXrpPoolFeeTierPPM,
        uint24 maxSlippagePPM,
        bytes21 stableCoinUsdFeedId,
        bytes21 wNatUsdFeedId
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
     * @notice Reverts if the feed ID is invalid (cannot be zero).
     */
    error InvalidFeedId();

    /**
     * @notice Reverts if the StableCoin (USDT0, USDX,...) token address is invalid.
     */
    error InvalidStableCoin();

    /**
     * @notice Reverts if the maximum slippage in PPM is invalid (must be less than or equal to 1e6).
     */
    error InvalidMaxSlippagePPM();

    /**
     * @notice Swaps WNAT for StableCoin (USDT0, USDX,...) for the personal account
               associated with the given XRPL address.
     * @param _xrplAddress The XRPL address of the personal account.
     */
    function swapWNatForStableCoin(
        string calldata _xrplAddress
    )
        external;

    /**
     * @notice Swaps StableCoin (USDT0, USDX,...) for FAsset for the personal account
               associated with the given XRPL address.
     * @param _xrplAddress The XRPL address of the personal account.
     */
    function swapStableCoinForFAsset(
        string calldata _xrplAddress
    )
        external;

    /**
     * Returns the swap parameters.
     * @return _uniswapV3Router The Uniswap V3 router address.
     * @return _stableCoin StableCoin (USDT0, USDX,...) token address.
     * @return _wNatStableCoinPoolFeeTierPPM The WNAT/StableCoin pool fee tier (in PPM).
     * @return _stableCoinFXrpPoolFeeTierPPM The StableCoin/FXRP pool fee tier (in PPM).
     * @return _maxSlippagePPM The maximum slippage allowed for swaps (in PPM).
     * @return _stableCoinUsdFeedId The StableCoin/USD feed ID as in FTSO.
     * @return _wNatUsdFeedId The WNAT/USD feed ID as in FTSO.
     */
    function getSwapParams()
        external view
        returns (
            address _uniswapV3Router,
            address _stableCoin,
            uint24 _wNatStableCoinPoolFeeTierPPM,
            uint24 _stableCoinFXrpPoolFeeTierPPM,
            uint24 _maxSlippagePPM,
            bytes21 _stableCoinUsdFeedId,
            bytes21 _wNatUsdFeedId
        );
}