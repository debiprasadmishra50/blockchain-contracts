// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract IfElse {
    function example(uint _x) external pure returns (uint) {
        if (_x < 10)
            return 1;
        else if (_x == 10) {
            return 2;
        } else {
            return 3;
        }
    }

    
    function ternary(uint _x) external pure returns (uint) {
        return _x > 10 ? 1 : 0;
    }


}