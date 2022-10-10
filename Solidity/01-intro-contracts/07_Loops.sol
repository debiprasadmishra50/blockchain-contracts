// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Loops {
    function loops() external pure {
        // For Loop
        for (uint256 i = 0; i < 10; i++) {
            // code
            if (i == 3) {
                continue;
            }
            
            // code
            if (i == 5)
                break;
        }

        // While Loop
        uint j = 0;
        while (j < 10) {
            // code
            j++;
        }

    }

    function add1ToN(uint _n) external pure returns (uint) {
        uint sum;
        for (uint8 i = 1; i < _n; i++) {
            sum += i;
        }

        return sum;
    }
}