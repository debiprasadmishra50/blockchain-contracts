// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/UniswapV2.sol";

/* 
    This contract will calculate the optimal amount to swap and then perform the swap and then finally add liquidity
*/
contract TestUniV2SwapOptimal {
    using SafeMath for uint256;

    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER02 =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // to do the trade
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // intermediary token we need for trade

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    /*
        s = optimal swap amount
        r = amount of reserve for token a
        a = amount of token a the user currently has (not added to reserve yet)
        f = swap fee percent = 0.3%
        s = (sqrt(((2 - f)r)^2 + 4(1 - f)ar) - (2 - f)r) / (2(1 - f))
    */
    function getSwapAmount(uint256 r, uint256 a) public pure returns (uint256) {
        return
            (sqrt(r.mul(r.mul(3988009) + a.mul(3988000))).sub(r.mul(1997))) /
            1994;
    }

    // swap and then add liquidity
    function zap(
        address _tokenA,
        address _tokenB,
        uint256 _amountA
    ) external {
        // transfer all the token to this contract
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

        // get the Exchange contract
        address pair = IUniswapV2Factory(FACTORY).getPair(_tokenA, _tokenB); // DAI to ETH

        // get reserves present for both token
        (uint256 reserve0, uint256 reserve1, ) = IUniswapV2Pair(pair)
            .getReserves();

        // calculate the swap amount
        uint256 swapAmount;
        if (IUniswapV2Pair(pair).token0() == _tokenA) {
            // swap from token0 to token1
            swapAmount = getSwapAmount(reserve0, reserve1);
        } else {
            // swap from token0 to token1
            swapAmount = getSwapAmount(reserve1, reserve0);
        }

        _swap(_tokenA, _tokenB, swapAmount);
        _addLiquidity(_tokenA, _tokenB);
    }

    /* sub-optimal one-sided supply
        1. swap half of token A to token B
        2. add liquidity
    */
    function subOptimalZap(
        address _tokenA,
        address _tokenB,
        uint256 _amountA
    ) external {
        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amountA);

        _swap(_tokenA, _tokenB, _amountA.div(2));
        _addLiquidity(_tokenA, _tokenB);
    }

    function _swap(
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        IERC20(_from).approve(ROUTER, _amount);

        address[] memory path = new address[](2);
        path = new address[](2);
        path[0] = _from;
        path[1] = _to;

        IUniswapV2Router(ROUTER).swapExactTokensForTokens(
            _amount,
            1,
            path,
            address(this),
            block.timestamp
        );
    }

    function _addLiquidity(address _tokenA, address _tokenB) internal {
        uint256 balA = IERC20(_tokenA).balanceOf(address(this));
        uint256 balB = IERC20(_tokenB).balanceOf(address(this));
        IERC20(_tokenA).approve(ROUTER, balA);
        IERC20(_tokenB).approve(ROUTER, balB);

        IUniswapV2Router(ROUTER).addLiquidity(
            _tokenA,
            _tokenB,
            balA,
            balB,
            0,
            0,
            address(this),
            block.timestamp
        );
    }
}
