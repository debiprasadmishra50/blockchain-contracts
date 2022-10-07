// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// used to reuse code
contract FunctionModifier {
    bool public paused;
    int public count;

    function setPause(bool _paused) external {
        paused = _paused;
    }

    modifier whenNotPaused(uint _x) {
        require(!paused, "paused");
        require(_x < 100, "x >= 100");
        _;
    }

    function increase(uint _x) external whenNotPaused(_x) {
        // require(!paused, "paused"); // written same logic twice
        count++;
    }
    
    function decrease(uint _x) external whenNotPaused(_x) {
        // require(!paused, "paused");
        count--;
    }

    // sandwich
    modifier sandwich() {
         // code here
        count += 10;
         _;
        //  more code
        count *= 2;
    }

    function foo() external sandwich {
        // if count is 0
        count += 1;

        // count will become 0 + 10, then 10 + 1, then 11 * 2 = 22
    }
}