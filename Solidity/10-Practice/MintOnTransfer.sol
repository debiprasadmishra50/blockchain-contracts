/* 

Create a ERC20 token contract that will support given feature ->
   if anyone transfer eth to  contract address  , it will mint some tokens for the user .
1ETH => 100 ERC20 tokens
    **Note -> user will not call any function

Include all utility functions and other function which you think might be useful in the working of the smart contract. 

 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MintOnTransfer is ERC20 {
    string private _name = "Test";
    string private _symbol = "TEST";
    uint private _rate = 100;

    event Received(address indexed from, uint indexed value, bytes data);
    event Minted(address indexed to, uint indexed token);

    constructor() ERC20(_name, _symbol) {}

    modifier validateEth() {
        require(msg.value > 0, "no eth sent");
        _;
    }

    receive() external payable validateEth {
        emit Received(msg.sender, msg.value, "");

        _mint(msg.sender, msg.value * _rate);
        emit Minted(msg.sender, msg.value * _rate);
    }

    fallback() external payable validateEth {
        emit Received(msg.sender, msg.value, msg.data);

        _mint(msg.sender, msg.value * _rate);
        emit Minted(msg.sender, msg.value * _rate);
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}
