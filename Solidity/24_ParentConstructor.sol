// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// 2 ways to call parent constuctors
// order of constructor execution happens with order of inheritance i.e.,
contract S {
    string public name;

    constructor(string memory _name) {
        name = _name;
    }
}

contract T {
    string public text;

    constructor(string memory _text) {
        text = _text;
    }
}

// one way, s and t are constructor inputs: static input
contract U is S("s"), T("t") {

}

// order of constructor execution happens with order of inheritance i.e., first S then T

// Another way, s and t are constructor inputs: dynamic input
contract V is S, T {
    constructor(string memory _name, string memory _text) S(_name) T(_text) {}
}

// static and dynamic input
contract VV is S("s"), T {
    constructor(string memory _text) T(_text) {}
}
