// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Counter {
    int public data;

    function increase() external {
        data++;
    }
    
    function decrease() external {
        data--;
    }
}