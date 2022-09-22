// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract Factory {
    Child[] public children;
    event ChildCreated(uint256 date, uint256 data, address childAddress);

    function createChild(uint256 _data) external {
        Child child = new Child(_data);
        children.push(child);

        emit ChildCreated(block.timestamp, _data, address(child));
    }
}

contract Child {
    uint256 data;

    constructor(uint256 _data) {
        data = _data;
    }
}
