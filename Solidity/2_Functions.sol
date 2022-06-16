// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Functions {
    function add(uint x, uint y) external pure returns(uint) { 
        // external: after deployed it can be accessed from outside solidity, not inside
        // pure: this is readonly function, does not write anything to blockchain
        // pure: This function will not modify or even read the contract's data

        return x + y;
    }

    function subtract(uint x, uint y) external pure returns(uint) {
        return x - y;
    }
}