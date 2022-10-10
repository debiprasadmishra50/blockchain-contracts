// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Variables {
    // Variables that store data into blockchain
    uint public stateVariable = 21;

    function foo() external pure {
        uint localVariable = 456;

        localVariable++;
    }

    // msg
    // block
    // now
    // tx
    // abi
    function globalVariables() external view returns (address, uint, uint) {
        address sender = msg.sender; // address that called this function
        uint timestamp = block.timestamp;
        uint blockNumber = block.number;

        return (sender, timestamp, blockNumber);
    }
}