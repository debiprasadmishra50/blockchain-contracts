// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract BitWiseOperators {
    function and(uint256 x, uint256 y) external pure returns (uint256) {
        return x & y;
    }

    function or(uint256 x, uint256 y) external pure returns (uint256) {
        return x | y;
    }

    function xor(uint256 x, uint256 y) external pure returns (uint256) {
        return x ^ y;
    }

    function not(uint256 x) external pure returns (uint256) {
        return ~x;
    }

    function shiftLeft(uint256 x, uint256 bits)
        external
        pure
        returns (uint256)
    {
        return x << bits;
    }

    function shiftRight(uint256 x, uint256 bits)
        external
        pure
        returns (uint256)
    {
        return x >> bits;
    }

    function getLastNBits(uint256 x, uint256 n)
        external
        pure
        returns (uint256)
    {
        uint256 mask = (1 << n) - 1;
        return x & mask;
    }

    function getLastNBitsUsingMod(uint256 x, uint256 n)
        external
        pure
        returns (uint256)
    {
        return x % (1 << n);
    }
}
