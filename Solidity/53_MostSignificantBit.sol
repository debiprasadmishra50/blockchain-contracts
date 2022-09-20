// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract MostSignificantBit {
    function findMostSignificantBit(uint256 x) external pure returns (uint8 r) {
        // is x >= 2^128
        if (x >= 2**128) {
            x >>= 128;
            r += 128;
        }
        // is x >= 2^64
        if (x >= 2**64) {
            x >>= 64;
            r += 64;
        }
        // is x >= 2^32
        if (x >= 2**32) {
            x >>= 32;
            r += 32;
        }
        // is x >= 2^16
        if (x >= 2**16) {
            x >>= 16;
            r += 16;
        }
        // is x >= 2^8
        if (x >= 2**8) {
            x >>= 8;
            r += 8;
        }
        // is x >= 2^4
        if (x >= 2**4) {
            x >>= 4;
            r += 4;
        }
        // is x >= 2^2
        if (x >= 2**2) {
            x >>= 2;
            r += 2;
        }
        // is x >= 2^1
        if (x >= 2) {
            r += 1;
        }
    }
}
