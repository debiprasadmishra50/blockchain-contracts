// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/UniswapV2.sol";

contract TestUniswap {
    address private constant UNISWAP_V2_ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // to do the trade
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // intermediary token we need for trade

    /* 
        User wants to trade DAI with WBTC, means user wants to receive WBTC in exchange of DAI
    */
    function swap(
        address _tokenIn,
        address _tokenOut,
        uint256 _amountIn,
        uint256 _amountOutMin, // Min expected output amount
        address _to // Ether address to send the o/p token to
    ) external {
        // transfer the tokenIn into this contract
        IERC20(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);

        // approve UniswapV2Router to send that token
        IERC20(_tokenIn).approve(UNISWAP_V2_ROUTER, _amountIn);

        // declare path addresses
        address[] memory path = new address[](3);
        path[0] = _tokenIn; // DAI
        path[1] = WETH; //
        path[2] = _tokenOut; // WBTC

        // then call swaptokens from V2Router
        IUniswapV2Router(UNISWAP_V2_ROUTER).swapExactTokensForTokens(
            _amountIn,
            _amountOutMin,
            path,
            _to,
            block.timestamp
        );
    }
}
