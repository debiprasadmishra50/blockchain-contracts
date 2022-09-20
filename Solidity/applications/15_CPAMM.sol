// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "./IERC20.sol";

/* 
    1. Deploy 2 ERC20, then pass their address and deploy CPAMM
    2. User1 is liquidity provider will call add and remove liquidity 
    3. User2 is a trader and will call swap
    4. mint 1000 tokens for user1 in both tokens
    5. approve CPAMM contract to spend 1000 tokens
    6. addLiquidity(1000,500) by user1
    8. check with the balanceOf of CPAMM giving user1 address, and getter functions
    9. switch to user2, mint 1000 tokens, approve CPAMM tokens token0: 100, and call swap(token0, 100)
    10. setich to user1, call the total shares user1 has using balanceOf of CSAMM, and call remove liquidity by providing the amount
    11. chech the reserves, should be 0
    12. check in the tokens with both users
*/
contract CPAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // keep track of reserve0 and reserve1
    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _to, uint256 _amount) private {
        balanceOf[_to] -= _amount;
        totalSupply -= _amount;
    }

    function _updateReserves(uint256 _reserve0, uint256 _reserve1) private {
        reserve0 = _reserve0;
        reserve1 = _reserve1;
    }

    /* do a trade b/w token0 and token1 */
    function swap(address _tokenIn, uint256 _amountIn)
        external
        returns (uint256 amountOut)
    {
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "invalid token"
        );
        require(_amountIn > 0, "amount in = 0");

        // pull in token in into this contract
        bool isToken0 = _tokenIn == address(token0);
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 reserveIn,
            uint256 reserveOut
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);

        // calculate token out(includes fees), fee is 0.3%
        // ydx / (x + dx) = dy
        // y = amount of tokenOut that is locked inside the contract
        // dx = amount of tokenIn that came in
        // x = amount of tokenIn that is locked inside the contract before the swap
        // dy = amount of tokenOut that will go out
        uint256 amountInWithFee = (_amountIn * 997) / 1000;
        amountOut =
            (reserveOut * amountInWithFee) /
            (reserveIn + amountInWithFee);

        // transfer tokenOut to msg.sender
        tokenOut.transfer(msg.sender, amountOut);

        // update the reserves
        _updateReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    /* adding liquidity and earn some rewards */
    function addLiquidity(uint256 _amount0, uint256 _amount1)
        external
        returns (uint256 shares)
    {
        // pull in token0 and token1
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);

        /* 
        to maintain the price of the token after adding liquidity, one has to follow this formula
            // dy / dx = y / x
            amount of token1 that comes in / token0 = reserve1 / reserve0
        */
        if (reserve0 > 0 || reserve1 > 0) {
            require(
                reserve0 * _amount1 == reserve1 * _amount0,
                "dy / dx != y / x"
            );
        }

        // mint shares
        // f(x,y) = value of liquidity = sqrt(xy);
        // s = dx / x * T = dy / y * T
        /* 
            s = amount of shares to mint
            T = total suppply
            dx = token0
            dy = amount of token that comes in
            y = reserve 1
            x = reserve 0
        */
        if (totalSupply == 0) {
            shares = _sqrt(_amount0 * _amount1);
        } else {
            shares = _min(
                (_amount0 * totalSupply) / reserve0,
                (_amount1 * totalSupply) / reserve1
            );
        }

        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        // update reserves
        _updateReserves(
            token0.balanceOf(address(this)),
            token1.balanceOf(address(this))
        );
    }

    function removeLiquidity(uint256 _shares)
        external
        returns (uint256 amount0, uint256 amount1)
    {
        // Calculate amount0 and amount1 to withdraw
        // dx = s / T * x
        // amount of token0 that goes out = shares / total supply * amount of token0 in the ccontract
        // dy = s / T * y
        // amount of token1 that goes out = shares / total supply * amount of token1 in the ccontract
        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));

        amount0 = (_shares * bal0) / totalSupply;
        amount1 = (_shares * bal1) / totalSupply;
        require(amount0 > 0 && amount1 > 0, "amoun0 or amount1 = 0");

        // Burn shares
        _burn(msg.sender, _shares);

        // Update reserves
        _updateReserves(bal0 - amount0, bal1 - amount1);

        // Transfer tokens to msg.sender
        token0.transfer(msg.sender, amount0);
        token1.transfer(msg.sender, amount1);
    }

    function _sqrt(uint256 y) private pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) + 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function _min(uint256 x, uint256 y) private pure returns (uint256) {
        return x <= y ? x : y;
    }
}
