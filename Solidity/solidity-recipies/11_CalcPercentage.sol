// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract CalcPercentage {
    // 185 basic points = 1.85%
    // check with 20000,10000,9000
    function calculateFee(uint256 _amount) external pure returns (uint256) {
        require((_amount / 10000) * 10000 == _amount, "too small");

        // return (_amount / 10000) * 185;
        return (_amount * 185) / 10000;
    }
}
