// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract HashFunc {
    // prettier-ignore
    function hash(string memory text, uint num, address addr) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text, num, addr));
    }

    // prettier-ignore
    function encode(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encode(text0, text1);
    }

    // try with: "AAA","ABBB" and "AAAA","BBB": Hash will be same
    // compresses the hash in encodePacked
    // prettier-ignore
    function encodePacked(string memory text0, string memory text1) external pure returns (bytes memory) {
        return abi.encodePacked(text0, text1);
    }

    // try with: "AAA","ABBB" and "AAAA","BBB": Hash will be same
    // encodePacked concatenates the inputs and encodes
    // prettier-ignore
    function collision(string memory text0, string memory text1) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text0, text1));
    }
}
