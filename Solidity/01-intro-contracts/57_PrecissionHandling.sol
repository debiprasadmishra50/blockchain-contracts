// // SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Precision {
    // 1 A -> 10 B
    uint256 conversionRate = 10;

    // If value =10000000 => 1A token. => 0.0000001
    // 1000000000000000000 => 1B Token => 0.000001

    // 10000000 => 0.1A *10 => 1*10**18
    // 1000000 => 0.01A

    // 1rupey 2decimal

    // 100paise. => 1rupey/100

    // 1 pakrupey 4 decimal

    // 10000 Pakpaise

    // 1rupey => 10Pak rupey

    // 100 paise *10 => 10000paise*10**4/10**2

    function convert(uint256 value) external view returns (uint256) {
        return (value * conversionRate * 10**18) / 10**8;
    }
}
