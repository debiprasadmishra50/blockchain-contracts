// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./ComptrollerInterface.sol";
import "./CTokenInterface.sol";

/* 
    DAI as collateral
    BAT as Borrow
*/
contract CompoundProject {
    IERC20 dai;
    CTokenInterface cDai;

    IERC20 bat;
    CTokenInterface cBat;

    ComptrollerInterface comptroller;

    constructor(
        address _dai,
        address _cDai,
        address _bat,
        address _cBat,
        address _comptoller
    ) {
        dai = IERC20(_dai);
        cDai = CTokenInterface(_cDai);
        bat = IERC20(_bat);
        cBat = CTokenInterface(_cBat);
        comptroller = ComptrollerInterface(_comptoller);
    }

    function invest() external {
        dai.approve(address(cDai), 10000); // approve cDAI to spend your 10000 tokens

        cDai.mint(10000); // invest 10000 DAI
    }

    function cashOut() external {
        uint256 balance = cDai.balanceOf(address(this));
        cDai.redeem(balance); // get back initial DAI invested in compound
    }

    function borrow() external {
        dai.approve(address(cDai), 10000);
        cDai.mint(10000); // invest 10000 DAI

        address[] memory markets = new address[](1);
        markets[0] = address(cDai);
        comptroller.enterMarkets(markets);

        cBat.borrow(100);
    }

    function payback() external {
        bat.approve(address(cBat), 200);
        cBat.repayBorrow(100);

        // Optional
        uint256 balance = cDai.balanceOf(address(this));
        cDai.redeem(balance);
    }
}
