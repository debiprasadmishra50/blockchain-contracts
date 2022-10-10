// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interfaces/compound.sol";

// supply
// borrow max
// wait few block and let borrowed_balance > supplied balance * col_factor
// liquidate

contract TestCompoundLiquidate {
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
    // close factor
    // liquidation incentive
    // liquidate
}
