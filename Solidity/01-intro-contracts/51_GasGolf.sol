// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

/* 
    gas saving techniques
    // start - ? gas
    // use calldata
    // load state variables to memory
    // short circuiting
    // loop increments
    // cache array length
    // load array elements to memory
*/
contract GasGolf {
    uint256 public total;

    // [1,2,3,4,5, 100]
    function sumIfevenAndLessThan99(uint256[] memory nums) external {
        for (uint256 i = 0; i < nums.length; i++) {
            bool isEven = nums[i] % 2 == 0;
            bool isLessThan99 = nums[i] < 99;
            if (isEven && isLessThan99) {
                total += nums[i];
            }
        }
    }
}

/* 




*/

/* 
After Gas Saving Techniques
    gas saving techniques
    // start - 58227 gas
    // use calldata - 56124 gas
    // load state variables to memory - 55881 gas
    // short circuiting - 55516 gas
    // loop increments
    // cache array length - 55475 gas
    // load array elements to memory - 55399
*/
contract GasGolfSaved {
    uint256 public total;

    // [1,2,3,4,5,100]
    // function sumIfevenAndLessThan99(uint256[] memory nums) external { // 1
    function sumIfevenAndLessThan99(uint256[] calldata nums) external {
        uint256 _total = total; // 2
        uint256 length = nums.length; // 5

        for (uint256 i = 0; i < length; i++) {
            // 4
            // bool isEven = nums[i] % 2 == 0;
            // bool isLessThan99 = nums[i] < 99;
            // if (isEven && isLessThan99) {
            uint256 num = nums[i]; // 6
            // if (nums[i] % 2 == 0 && nums[i] < 99) { // 3
            if (num % 2 == 0 && num < 99) {
                // 3
                _total += nums[i];
            }
        }

        total = _total;
    }
}
