// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract ArrayShift {
    uint[] public arr;

    function create() public {
        arr = [1, 2, 3, 4, 5, 6];
        delete arr[1];
    }

    function remove(uint _index) public {
        require(_index < arr.length, "index out of bound");

        for (uint256 i = _index; i < arr.length - 1; i++) {
            arr[i] = arr[i+1];
        }
        arr.pop();
    }

    function readArray() public view returns (uint[] memory) {
        return arr;
    }
}