// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Payable {
    address payable public owner; // owner will be able to send eth

    constructor ( ) {
        owner = payable(msg.sender);
    }

    function deposit() external payable {
        
    }

    function getBalance() external view returns (uint) {
        return address(this).balance;
    }
}