// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/* 
    Block the money moving in and out of the contract in case of a hack
*/

contract Factory {
    address owner;
    bool public isActive = true;

    constructor() {
        // owner can become a multi-sig wallet
        owner = msg.sender;
    }

    function toggleCircuit() external {
        require(msg.sender == owner);
        isActive = !isActive;
    }
}

contract CircuitBreaker {
    modifier contractIsActive() {
        // Factory(Factory deploy contract address)
        require(
            Factory(0xf8e81D47203A594245E36C48e151709F0C19fBe8).isActive() ==
                true
        );
        _;
    }

    function withdraw() external contractIsActive {}

    receive() external payable {}
}
