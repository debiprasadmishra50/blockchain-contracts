// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/UniswapV2.sol";

contract TestUniswap {
    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER02 =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // to do the trade
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // intermediary token we need for trade

    event Log(string message, uint256 val);

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 _amountA,
        uint256 _amountB
    ) external {
        // Transfer the tokens to this token
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);
        IERC20(_tokenB).transferFrom(msg.sender, address(this), _amountB);

        // allow uniswap to spend those tokens
        IERC20(_tokenA).approve(ROUTER02, _amountA);
        IERC20(_tokenB).approve(ROUTER02, _amountB);

        // call the add liquidity token
        (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ) = IUniswapV2Router(ROUTER02).addLiquidity(
                _tokenA,
                _tokenB,
                _amountA,
                _amountB,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit Log("amountA uniswap took", amountA);
        emit Log("amountB uniswap took", amountB);
        emit Log("Liquidity", liquidity);
    }

    function removeLiquidity(address _tokenA, address _tokenB) external {
        // get the exchange contract for tokenA and tokenB
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB);

        // get the total liquidity(LP) tokens this contract has
        uint256 liquidity = IERC20(pair).balanceOf(address(this));

        // allow Router to spend the LP tokens
        IERC20(pair).approve(ROUTER02, liquidity);

        (uint256 amountA, uint256 amountB) = IUniswapV2Router(ROUTER02)
            .removeLiquidity(
                _tokenA,
                _tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit Log("amountA received", amountA);
        emit Log("amountB received", amountB);
    }
}
