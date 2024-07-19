// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./interfaces/IUniswapV2Factory.sol";

contract TestUniswapV2 {
    address private constant UNIV2_FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant UNIV2_ROUTER02 =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // to do the trade
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // intermediary token we need for trade

    function getPair(address token1, address token2)
        external
        view
        returns (address)
    {
        address pair = IUniswapV2Factory(UNIV2_FACTORY).getPair(token1, token2);

        return pair;
    }
}
