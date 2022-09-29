// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

// https://eips.ethereum.org/EIPS/eip-165
// EIP 1820 is a modification of this EIP
/* Tells other smart contracts which function it implements */

contract B {
    mapping(bytes4 => bool) private _interfaces;

    constructor() {
        B b;
        _interfaces[b.foo.selector ^ b.bar.selector] = true;
        _interfaces[0x01ffc9a7] = true; // function selector of supportsInterface function, registering the inner funtion
    }

    // function calculateInterfaceId() public pure returns (bytes4) {
    //     // return bytes4(keccak256("foo()"));
    //     // return bytes4(keccak256("foo()")) ^ bytes4(keccak256("bar()"));

    //     B b;
    //     return b.foo.selector ^ b.bar.selector;
    // }

    function supportsInterface(bytes4 interfaceid)
        external
        view
        returns (bool)
    {
        return _interfaces[interfaceid];
    }

    function foo() external {
        // implementation
    }

    function bar() external {
        // implementation
    }

    function baz() external {
        // implementation
    }
}

contract A {
    /* 
        - A wants to call a function from B, but A does not know whether B contains the function A wants to call

        - ERC165 provides a mechanism for B to publish the function it implements and A will be able to know it in advance which function B implements

        - 
    */
    function callFoo() external {
        // STATICCALL
        if (contractB.supportsInterface(0x14d12a4)) {
            contractB.foo();
        } else {
            revert("contract does not implement ...");
        }
    }
}
