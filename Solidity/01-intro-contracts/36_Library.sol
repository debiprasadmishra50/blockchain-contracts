// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

library Math {
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }
}

contract Test {
    function testMax(uint256 x, uint256 y) external pure returns (uint256) {
        return Math.max(x, y);
    }
}

library ArrayLib {
    // prettier-ignore
    function find(uint[] storage arr, uint x) internal view returns (uint) {
        for (uint256 i = 0; i < arr.length; i++) {
            if (arr[i] == x) return i;
        }

        revert("not found");
    }
}

contract TestArray {
    using ArrayLib for uint256[];

    uint256[] public arr = [1, 2, 3];

    function testFind() external view returns (uint256 i) {
        // i = ArrayLib.find(arr, 2);
        i = arr.find(2);
    }
}
