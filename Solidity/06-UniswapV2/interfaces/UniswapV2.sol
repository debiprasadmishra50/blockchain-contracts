// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniswapV2Router {
    /* 
        Swap a token for another token
        amountIn: Amount of token that we want to trade in for
        amountOutMin: The minimum amount of tokens that we want from this trade
        path: list of token addresses that we want this trade to happen
        to: address of the token that we will be sending the output tokens to
        deadline: last timestamp this trade is valid
    */
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
}
