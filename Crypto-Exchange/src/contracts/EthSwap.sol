// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

import "./Token.sol";

contract EthSwap {
    string public name = "EthSwap Instant Exchange";
    Token public token;
    uint256 public rate = 100;

    event TokensPurchased(
        address indexed buyer,
        address indexed token,
        uint256 indexed amount,
        uint256 rate
    );

    event TokensSold(
        address indexed buyer,
        address indexed token,
        uint256 indexed amount,
        uint256 rate
    );

    constructor(Token _token) public {
        token = _token;
    }

    function buyTokens() public payable {
        // Redemption rate = no of tokens they receive for 1 ether
        // Amount of ethereum * redemption rate
        // Calculate the number of tokens to buy
        uint256 tokenAmount = msg.value * rate;
        require(
            token.balanceOf(address(this)) >= tokenAmount,
            "not enough tokens"
        );

        // Transfer tokens to the user
        token.transfer(msg.sender, tokenAmount);

        // emit an event
        emit TokensPurchased(msg.sender, address(token), tokenAmount, rate);
    }

    function sellTokens(uint256 _amount) public payable {
        // User can't sell more tokens than they have
        require(token.balanceOf(msg.sender) >= _amount, "not enough tokens");

        // Transfer tokens from the user to EthSwap and return the Ether

        // calculate amount of ether to redeem
        uint256 etherAmount = _amount / rate;

        require(
            address(this).balance >= etherAmount,
            "not enough ether to send"
        );

        // Perform Sale
        token.transferFrom(msg.sender, address(this), _amount);
        msg.sender.transfer(etherAmount);

        emit TokensSold(msg.sender, address(token), _amount, rate);
    }
}
