// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Intro {
    string public name;
    address public owner;

    constructor() {
        name = "Debi";
        owner = msg.sender;
    }

    function setName(string memory _name) external {
        name = _name;
    }
}
