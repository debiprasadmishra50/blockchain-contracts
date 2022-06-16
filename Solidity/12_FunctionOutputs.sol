// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract FunctionOutput {
    
    function returnMany() public pure returns (uint, bool) {
        return (1, true);
    }
    
    function returnNamed() public pure returns (uint x, bool b) {
        return (1, true);
    }
    
    function assigned() public pure returns (uint x, bool b) {
        x = 1;
        b = true;
    }
    
    function destructionAssignment() public pure {
        (uint x, bool b) = returnMany();
        (, bool _b) = returnMany();

        x++;
        b = false;
        _b = false;
    }
}