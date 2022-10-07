// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

// Iterable Mapping
contract Mapping {
    mapping(string => bool) students;

    mapping(address => uint256) balances;
    mapping(address => bool) inserted;
    address[] public keys;

    // nested mapping: whether an address is friend of another address
    mapping(address => mapping(address => bool)) friend;

    constructor() {}

    function create() external {
        students["alice"] = true;
        students["bob"] = true;
        students["charlie"] = true;

        balances[msg.sender] = 123;

        friend[msg.sender][address(this)] = true;
    }

    function set(address _key, uint256 _val) external {
        balances[_key] = _val;

        if (!inserted[_key]) {
            inserted[_key] = true;
            keys.push(_key);
        }
    }

    function getSize() external view returns (uint256) {
        return keys.length;
    }

    function getFirst() external view returns (uint256) {
        return balances[keys[0]];
    }

    function getLast() external view returns (uint256) {
        return balances[keys[keys.length - 1]];
    }

    function get(uint256 _i) external view returns (uint256) {
        return balances[keys[_i]];
    }
}
