// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Functions {
    address public owner;
    uint public x;

    constructor (uint _x) {
        owner = msg.sender;
        x = _x;
    }
}