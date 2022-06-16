// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// Multi-Level inheritance
contract A {
    // virtual: this function can be inherited and can be customizable
    function foo() public pure virtual returns (string memory) {
        return "A";
    }

    function bar() public pure virtual returns (string memory) {
        return "A";
    }
    
    function lao() public pure returns (string memory) {
        return "A";
    }

    // more code
}

contract B is A {
    function foo() public pure override returns (string memory) {
        return "B";
    }

    function bar() public pure virtual override returns (string memory) {
        return "B";
    }
}

contract C is B {
    function bar() public pure override returns (string memory) {
        return "C";
    }
}



// Multiple Inheritance
// order of inheritance: most base-like to derived, order is important
// base-like: the contract that derives less no of contracts

contract X {
    function foo() public pure virtual returns (string memory) {
        return "X";
    }

    function bar() public pure virtual returns (string memory) {
        return "X";
    }
    
    function lao() public pure returns (string memory) {
        return "X";
    }
}

contract Y is X {
    function foo() public pure virtual override returns (string memory) {
        return "Y";
    }

    function bar() public pure virtual override returns (string memory) {
        return "Y";
    }
    
    function y() public pure returns (string memory) {
        return "Y";
    }
}

contract Z is X, Y {
     function foo() public pure override(X, Y) returns (string memory) {
        return "Z";
    }

    function bar() public pure override(X, Y) returns (string memory) {
        return "Z";
    }
}