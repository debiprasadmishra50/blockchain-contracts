// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/Compound.sol";

// supply
// borrow max
// wait few block and let borrowed_balance > supplied balance * col_factor
// liquidate

contract TestCompoundLiquidate {
    // MAINNET ADDRESS
    Comptroller public comptroller =
        Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    PriceFeed public priceFeed =
        PriceFeed(0x922018674c12a7F0D394ebEEf9B58F186CdE13c1);

    IERC20 public tokenSupply;
    CErc20 public cTokenSupply;
    IERC20 public tokenBorrow;
    CErc20 public cTokenBorrow;

    event Log(string message, uint256 val);

    constructor(
        address _tokenSupply,
        address _cTokenSupply,
        address _tokenBorrow,
        address _cTokenBorrow
    ) {
        tokenSupply = IERC20(_tokenSupply);
        cTokenSupply = CErc20(_cTokenSupply);

        tokenBorrow = IERC20(_tokenBorrow);
        cTokenBorrow = CErc20(_cTokenBorrow);
    }

    function supply(uint256 _amount) external {
        tokenSupply.transferFrom(msg.sender, address(this), _amount);
        tokenSupply.approve(address(cTokenSupply), _amount);
        require(cTokenSupply.mint(_amount) == 0, "mint failed");
    }

    // NOT VIEW function
    function getSupplyBalance() external returns (uint256) {
        return cTokenSupply.balanceOfUnderlying(address(this));
    }

    function getCollateralFactor() external view returns (uint256) {
        (, uint256 colFactor, ) = comptroller.markets(address(cTokenSupply));
        return colFactor; // divide by 1e18 to get in %
    }

    function getAccountLiquidity()
        external
        view
        returns (uint256 liquidity, uint256 shortfall)
    {
        // liquidity and shortfall in USD scaled up by 1e18
        (uint256 error, uint256 _liquidity, uint256 _shortfall) = comptroller
            .getAccountLiquidity(address(this));
        require(error == 0, "error");
        return (_liquidity, _shortfall);
    }

    function getPriceFeed(address _cToken) external view returns (uint256) {
        // scaled up by 1e18
        return priceFeed.getUnderlyingPrice(_cToken);
    }

    function enterMarket() external {
        address[] memory cTokens = new address[](1);
        cTokens[0] = address(cTokenSupply);
        uint256[] memory errors = comptroller.enterMarkets(cTokens);
        require(errors[0] == 0, "Comptroller.enterMarkets failed.");
    }

    function borrow(uint256 _amount) external {
        require(cTokenBorrow.borrow(_amount) == 0, "borrow failed");
    }

    // not view function
    function getBorrowBalance() public returns (uint256) {
        return cTokenBorrow.borrowBalanceCurrent(address(this));
    }
}

contract CompoundLiquidator {
    Comptroller public comptroller =
        Comptroller(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);

    IERC20 public tokenBorrow;
    CErc20 public cTokenBorrow;

    constructor(address _tokenBorrow, address _cTokenBorrow) {
        tokenBorrow = IERC20(_tokenBorrow);
        cTokenBorrow = CErc20(_cTokenBorrow);
    }

    /* 
        close factor
            - max percentage of the borrow token that can be repaid
            - if a person has borrowed 100 DAI and the close factor is 50%, we can repay upto 50% of 100 DAI that was borrowed

        liquidation incentive
            - when we call liquidate, we repay a portion of the token that was borrowed by another account
            - in return you are rewarded with a portion of the token that was supplied as collateral
            - you'll receive the collateral at a discount
            - it's called liquidation incentive

        liquidate
    */
    // CLOSE FACTOR
    function getCloseFactor() external view returns (uint256) {
        // scaled up by 10^18,
        // to get percentage, divide the amount by 10^18
        return comptroller.closeFactorMantissa();
    }

    // LIQUIDATION INCENTIVE
    function getLiquidationIncentive() external view returns (uint256) {
        return comptroller.liquidationIncentiveMantissa();
    }

    // get amount of collateral to be liquidated
    function getAmountToBeLiquidated(
        address _cTokenBorrowed,
        address _cTokenCollateral,
        uint256 _actualRepayAmount
    ) external view returns (uint256) {
        /* 
          Get exchange rate and calculate the number of collateral tokens to seize:

          seizeAmount = actualRepayAmount * liquidationIncentive * priceBorrowed / priceCollateral

          seizeTokens = seizeAmount / exchangeRate
            = actualRepayAmount * (liquidationIncentive * priceBorrowed) / (priceCollateral * exchangeRate)

        */

        (uint256 _error, uint256 cTokenCollateralAmount) = comptroller
            .liquidateCalculateSeizeTokens(
                _cTokenBorrowed,
                _cTokenCollateral,
                _actualRepayAmount
            );

        require(_error == 0, "error");

        return cTokenCollateralAmount;
    }

    // LIQUIDATE
    // borrower address, amount that we will repay, cTokenCollateral we will receive in return for liquidating
    function liquidate(
        address _borrower,
        uint256 _repayAmount,
        address _cTokenCollateral
    ) external {
        // transfer the _repayAmount from sender to this contract
        tokenBorrow.transferFrom(msg.sender, address(this), _repayAmount);
        // approve cTokenBorrow to be able to spend _repayAmount
        tokenBorrow.approve(address(cTokenBorrow), _repayAmount);

        require(
            cTokenBorrow.liquidateBorrow(
                _borrower,
                _repayAmount,
                CErc20(_cTokenCollateral)
            ) == 0,
            "liquidate failed"
        );
    }
}
