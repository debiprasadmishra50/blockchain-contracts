// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./interfaces/UniswapV1.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// https://github.com/Uniswap/v1-docs

contract DeFIUniswapV1 {
    UniswapFactoryInterface uniswapFactory;

    function setup(address _uniswapFactoryAddress) external {
        uniswapFactory = UniswapFactoryInterface(_uniswapFactoryAddress);
    }

    // _token: ERC20 Token
    // create a new exchange / liquidity pool
    function createExchange(address _token) external {
        uniswapFactory.createExchange(_token);
    }

    // address of token you want to trade
    // amount of token you want to trade
    function buy(address _token, uint256 _amount) external payable {
        // get tokens exchange address
        UniswapExchangeInterface exchangeContract = UniswapExchangeInterface(
            uniswapFactory.getExchange(_token)
        );

        // get how much token you can get with the ETH
        uint256 tokenAmount = exchangeContract.getEthToTokenInputPrice(
            msg.value
        ); // the amount of token you can get from the ETH

        // make the exchange
        exchangeContract.ethToTokenTransferInput.value(msg.value)(
            tokenAmount,
            now + 120 seconds,
            msg.sender
        );
    }

    // Become a liquidity provider
    // address of the token you will provide
    // also you will send same amount of ETH
    function addLiquidity(address _token) external payable {
        // get tokens exchange address
        UniswapExchangeInterface exchangeContract = UniswapExchangeInterface(
            uniswapFactory.getExchange(_token)
        );

        // get how much token you can get with the ETH
        uint256 tokenAmount = exchangeContract.getEthToTokenInputPrice(
            msg.value
        );
        // exchangeContract.getEthToTokenInputPrice(eth_sold);

        // before transfer, approve the uniswap to be able to spend your ERC20 Token
        IERC20(_token).transferFrom(msg.sender, address(this), tokenAmount);

        exchangeContract.addLiquidity.value(msg.value)(
            tokenAmount,
            tokenAmount,
            now + 120 seconds
        );
        // exchangeContract.addLiquidity(min_liquidity, max_tokens, deadline);
    }
}
