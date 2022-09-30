// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/* 
    Constant Sum Automated Market Maker
    
    1. Deploy 2 ERC20 contracts
    2. pass the addresses and deploy CSAMM
    3. Mint 100 token in Token0 and Token1 for User0
    4. execute approve() in both ERC20, User0, spender = CSAMM addr, value 100
    5. execute addLiquidity in CSAMM, value: 100
    6. execute balanceOf User0, reserve0, reserve1, totalSupply
    7. switch to User1 and mint 100 tokens in token0 and token1
    8. let's say User1 will sell token0 for token1
    9. approve() 10 tokens to CSAMM: User1
    10. swap() in CSAMM: token0 address and 10
    11. switch to user0
    12. balanceOf in CSAMM for user0 and put the result in the removeLiquidity() function
    13. reserve0, reserve1, totalSupply will be 0
*/

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    /* Keep track of balance for respected tokens */
    uint256 public reserve0;
    uint256 public reserve1;

    uint256 public totalSupply;
    /* Shares per user: user_address => amount_of_shares  */
    mapping(address => uint256) public balanceOf;

    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    /* _to: account to mint the shares to */
    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    /* _from: account to burn the shares from */
    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    function _updateReserves(uint256 _res0, uint256 _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    /* 
        swap is called to trade one token for another token 
        _tokenIn: address of the token that the user is selling
        _amountIn: amount of token the user is selling

        return the amount of other token that was returns to the user
    */
    function swap(address _tokenIn, uint256 _amountIn)
        external
        returns (uint256 amountOut)
    {
        require(
            _tokenIn == address(token0) || _tokenIn == address(token1),
            "invalid token"
        );

        bool isToken0 = _tokenIn == address(token0);
        (
            IERC20 tokenIn,
            IERC20 tokenOut,
            uint256 resIn,
            uint256 resOut
        ) = isToken0
                ? (token0, token1, reserve0, reserve1)
                : (token1, token0, reserve1, reserve0);

        // // transfer tokenIn into this contract
        // uint256 amountIn;
        // if (_tokenIn == address(token0)) {
        //     token0.transferFrom(msg.sender, address(this), _amountIn);
        //     amountIn = token0.balanceOf(address(this)) - reserve0;
        // } else {
        //     token1.transferFrom(msg.sender, address(this), _amountIn);
        //     amountIn = token1.balanceOf(address(this)) - reserve1;
        // }
        /* REFACTORED CODE */
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint256 amountIn = tokenIn.balanceOf(address(this)) - resIn;

        // calculate amountOut (including fees)
        // dx = dy (amount of tokenIn = amount of token out)
        // trading fee = 0.3%
        amountOut = (amountIn * 997) / 1000;

        // // update the reserves (reserve0 and reserve1)
        // if (_tokenIn == address(token0)) {
        //     _updateReserves(reserve0 + _amountIn, reserve1 - amountOut);
        // } else {
        //     _updateReserves(reserve0 - _amountIn, reserve1 + amountOut);
        // }
        /* REFACTORED CODE */
        (uint256 res0, uint256 res1) = isToken0
            ? (resIn + _amountIn, resOut - amountOut)
            : (resOut - _amountIn, resIn + amountOut);
        _updateReserves(res0, res1);

        // // transfer token out
        // if (_tokenIn == address(token0)) {
        //     token1.transfer(msg.sender, amountOut);
        // } else {
        //     token0.transfer(msg.sender, amountOut);
        // }
        /* REFACTORED CODE */
        tokenOut.transfer(msg.sender, amountOut);
    }

    /* addLiquidity is called to add token */
    // the amount of tokens to put inside this AMM
    function addLiquidity(uint256 _amount0, uint256 _amount1)
        external
        returns (uint256 shares)
    {
        /* transfer token0 and token1 into this contract */
        token0.transferFrom(msg.sender, address(this), _amount0);
        token1.transferFrom(msg.sender, address(this), _amount1);
        /* get the current token balance  */
        uint256 bal0 = token0.balanceOf(address(this));
        uint256 bal1 = token1.balanceOf(address(this));
        /* get the actual amount of tokens that came in */
        uint256 d0 = bal0 - reserve0;
        uint256 d1 = bal1 - reserve1;

        /* 
            a = amount in
            L = total liquidity
            s = shares to mint
            T = total supply

            (L+a) / L = (T + s) / T

            s = a * T / L
        */
        if (totalSupply == 0) {
            shares = d0 + d1;
        } else {
            shares = ((d0 + d1) * totalSupply) / (reserve0 + reserve1);
        }

        require(shares > 0, "shares = 0");
        _mint(msg.sender, shares);

        _updateReserves(bal0, bal1);
    }

    /* removeLiquidity is called to remove token */
    // they are burning their shares, in return they're getting some tokens locked in the contract back
    // returns amount of tokens returned to user(token0 and token1)
    function removeLiquidity(uint256 _shares)
        external
        returns (uint256 d0, uint256 d1)
    {
        /* 
            a = amount in
            L = total liquidity
            s = shares to mint
            T = total supply

            a / L = s / T

            a = (L * s) / T
              = (reserve0 + reserve1) * s / T
        */
        d0 = (reserve0 * _shares) / totalSupply;
        d1 = (reserve1 * _shares) / totalSupply;

        _burn(msg.sender, _shares);
        _updateReserves(reserve0 - d0, reserve1 - d1);

        if (d0 > 0) {
            token0.transfer(msg.sender, d0);
        }
        if (d1 > 0) {
            token1.transfer(msg.sender, d1);
        }
    }
}
