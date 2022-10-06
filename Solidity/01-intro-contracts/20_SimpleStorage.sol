// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract SimpleStorage {
    string public text;

    constructor() {}

    function set(string calldata _text) external {
        text = _text;
    }

    function get() external view returns (string memory) {
        return text;
    }
}
