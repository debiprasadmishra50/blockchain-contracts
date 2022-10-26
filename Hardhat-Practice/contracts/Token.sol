// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Token {
    string public name = "My Token";
    string public symbol = "DMT";
    uint public totalSupply = 1000000;
    address public owner;

    mapping(address => uint) public balanceOf;

    constructor() {
        owner = msg.sender;
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint _amount) external {
        require(balanceOf[msg.sender] >= _amount, "insufficient funds");

        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;
    }
}
