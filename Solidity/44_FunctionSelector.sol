// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract FunctionSelector {
    // input: "transfer(address,uint256)"
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }

}

contract Receiver {
    event Log(bytes data );

    function transfer(address _to, uint _amount) external {
        _to; _amount;
        
        emit Log(msg.data);
    }
}