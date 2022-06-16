// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract Arrays {
    uint[] public age; // dynamic
    uint[10] public score; // fixed size array with 10 size
    uint[] public height = [1, 2, 3]; // dynamic with initial elements
    uint[3] public length = [10, 20, 30];

    function example() external {
        age.push(4);

        uint ramAge = age[0];
        ramAge += 1;

        height[1] = 100; // [1, 100, 3]

        delete height[0]; // [0, 100, 3]

        height.pop(); // [0, 100]


        // create array in memory
        uint[] memory arr = new uint[](5);
        // arr.push(1); // not available for memory
        // arr.pop();
        arr[1] = 10;
    }

    function returnArray() external view returns (uint[] memory) {
        return height;
    }
}