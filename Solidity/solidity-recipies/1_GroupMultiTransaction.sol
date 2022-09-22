// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract A {
    function foo(uint256 arg) external pure returns (uint256) {
        // something
        return arg * 2;
    }
}

contract B {
    function bar(uint256 arg) external pure returns (uint256) {
        // something else
        return arg * 3;
    }
}

contract Utils {
    function groupExecute(
        address addr1,
        address addr2,
        uint256 arg1,
        uint256 arg2
    ) external pure returns (uint256 a, uint256 b) {
        a = A(addr1).foo(arg1);
        b = B(addr2).bar(arg2);
    }
}
