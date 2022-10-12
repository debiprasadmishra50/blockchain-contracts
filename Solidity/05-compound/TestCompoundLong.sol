// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* 
Long and Short on Compound
What is Long and Short
    - you can potentially earn crypto assets by betting on the price going up or going down, this is called long and short
    - When you bet the price of ETH will go up in thhe future, this is called Long ETH

How you can earn by betting on the price of ETH going UP: Long ETH
    - Assuming I have 10 ETH and I supplied this 10 ETH to compound
    - After supply, I will be able borrow another crypto asset, here DAI. for 10 ETH and borrowed 300 DAI
    - let's say the collateral ratio on the compound is 65% but we can't borrow upto 65% becuase then my ETH will be liquidated.
    - to be safe, we will borrow amount i.e, less than collateral ratio
    - borrow 30% of the collateral ratio to be safe = 300 DAI
    - 1 ETH = $100, 1 DAI = $1, 10 ETH = $1000, 30% is 300 = 300 DAI
    - use 300 DAI to buy 3 more ETH
    - IF THE PRICE OF ETH DOUBLED
    - sell 1.5 ETH to get back 300 borrowed DAI
    - Repay 300 DAI to compound and you made 1.5 ETH profit

How you can earn by betting on the price of ETH going DOWN: Short ETH
    - let's say the price of ETH is $200 today
    - I predict in 1 week it will hit $100
    - let's assume I have 1000 DAI, I'll supply this 1000 DAI to compound
    - I used the DAI as collateral and borrowed 1.5 ETH
    - collateral ratio is 65%, we have to borrow less than collateral ratio, here 30%
    - 30% of 1000DAI = 300DAI worth of ETH can be borrowed. 
    - 1 ETH = $200, 300 DAI = 1.5ETH
    - sell the ETH immediately for DAI and we will get 300 DAI
    - IF THE PRICE WENT DOWN BY HALF
    - take the 300 DAI, buy 1.5 ETH by giving 150 DAI
    - repay 1.5ETH to compound and ou just made 150DAI in profit

Code
Demo
*/

/* 
    Long ETH
        1. Supply ETH
        2. burrow stable coin (DAI, USDC)
        3. buy ETH on UniSwap

        when the price of ETH goes up
        4. sell the ETH on UniSwap
        5. repay borrowed stable coin
        
*/
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/Compound.sol";
import "./interfaces/Uniswap.sol";

contract TestCompoundLong {
    CEth public cEth;
    CErc20 public cTokenBorrow;
    IERC20 public tokenBorrow;
    uint256 public decimals;

    Comptroller public comptroller =
        Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    PriceFeed public priceFeed =
        PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);

    IUniswapV2Router private constant UNI =
        IUniswapV2Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IERC20 private constant WETH =
        IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    constructor(
        address _cEth,
        address _cTokenBorrow,
        address _tokenBorrow,
        uint256 _decimals
    ) {
        cEth = CEth(_cEth);
        cTokenBorrow = CErc20(_cTokenBorrow);
        tokenBorrow = IERC20(_tokenBorrow);
        decimals = _decimals;

        // enter the market to enable borrow
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cEth);
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        require(errors[0] == 0, "Comptroller.enterMarkets failed");
    }

    receive() external payable {} // enable contract to receive ether from Uniswap and Compound

    function supply() external payable {
        cEth.mint(msg.value);
    }

    // how much max amount of DAI you can borrow after supplying ETH
    function getMaxBorrow() external view returns (uint256) {
        (uint256 _error, uint256 liquidity, uint256 shortfall) = comptroller
            .getAccountLiquidity(address(this));

        require(_error == 0, "error");
        require(shortfall == 0, "shortfall > 0");
        require(liquidity > 0, "liquidity = 0");

        uint256 price = priceFeed.getUnderlyingPrice(address(cTokenBorrow));

        uint256 maxBorrow = (liquidity * (10**decimals)) / price;

        return maxBorrow;
    }

    function long(uint256 _borrowAmount) external {
        // borrow
        require(cTokenBorrow.borrow(_borrowAmount) == 0, "borrow failed");

        // buy ETH
        uint256 bal = tokenBorrow.balanceOf(address(this));
        tokenBorrow.approve(address(UNI), bal);

        address[] memory path = new address[](2);
        path[0] = address(tokenBorrow);
        path[1] = address(WETH);
        UNI.swapExactTokensForETH(bal, 1, path, address(this), block.timestamp);
    }

    // after the price went up, now we can claim profit
    function repay() external {
        // sell ETH
        address[] memory path = new address[](2);
        path[0] = address(WETH);
        path[1] = address(tokenBorrow);
        UNI.swapExactETHForTokens{value: address(this).balance}(
            1,
            path,
            address(this),
            block.timestamp
        );

        // repay borrowed token
        uint256 borrowed = cTokenBorrow.borrowBalanceCurrent(address(this));
        tokenBorrow.approve(address(cTokenBorrow), borrowed);
        require(cTokenBorrow.repayBorrow(borrowed) == 0, "repay failed");

        uint256 supplied = cEth.balanceOfUnderlying(address(this));
        require(cEth.redeemUnderlying(supplied) == 0, "redeem failed");

        // supplied ETH + supplied interest + profit(in token borrow)
    }
}
