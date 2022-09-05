// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

contract FunctionSelector {
    // input: "transfer(address,uint256)"
    // first 4 bytes of the hash of the function selector
    function getSelector(string calldata _func) external pure returns (bytes4) {
        return bytes4(keccak256(bytes(_func)));
    }
}

contract Receiver {
    event Log(bytes data);

    function transfer(address _to, uint256 _amount) external {
        _to;
        _amount;

        emit Log(msg.data);
    }
    /* 
        0xa9059cbb: first 4 bytes of the hash of function selector
        These are the arguments to the function
        0000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4
        0000000000000000000000000000000000000000000000000000000000000064
     */
}
