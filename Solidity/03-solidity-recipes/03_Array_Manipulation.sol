// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract MyContract {
    uint256[] public data;

    constructor() {
        data.push(1);
        data.push(2);
        data.push(3);
        data.push(4);
        data.push(5);
    }

    /* Array not in order */
    function removeNoOrder(uint256 index) external {
        data[index] = data[data.length - 1];
        data.pop();
    }

    /* Array in order */
    function removeInOrder(uint256 index) external {
        for (uint256 i = index; i < data.length - 1; i++) {
            data[i] = data[i + 1];
        }
        data.pop();
    }
}
