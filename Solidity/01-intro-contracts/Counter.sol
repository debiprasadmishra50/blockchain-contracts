// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Counter {
    uint256 public counter;

    function increase(uint256 val) external {
        counter += val;
    }

    function decrease(uint256 val) external {
        counter -= val;
    }

    function inc() external {
        ++counter;
    }

    function dec() external {
        --counter;
    }
}
