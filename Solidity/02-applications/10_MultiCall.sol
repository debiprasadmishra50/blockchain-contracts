// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract TestMultiCall {
    function fun1() external view returns (uint256, uint256) {
        return (1, block.timestamp);
    }

    function fun2() external view returns (uint256, uint256) {
        return (2, block.timestamp);
    }

    function getData1() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.fun1.selector);
    }

    function getData2() external pure returns (bytes memory) {
        return abi.encodeWithSelector(this.fun2.selector);
    }
}

/*  
    Execute multiple function calls to a single contract using a single MultiCall contract.
*/

contract MultiCall {
    /* 
        use staticcall to query/read the functions, view functions
        use call to make transactions and remove view as it will write data to blockchain

        targets: address of the contracts to call
        data: function data to be called for
    */
    function multiCall(address[] calldata targets, bytes[] calldata data)
        external
        view
        returns (bytes[] memory)
    {
        require(targets.length == data.length, "target length != data.length");
        bytes[] memory results = new bytes[](data.length);

        for (uint256 i = 0; i < targets.length; i++) {
            (bool success, bytes memory result) = targets[i].staticcall(
                data[i]
            );
            require(success, "call failed");
            results[i] = result;
        }

        return results;
    }
}

/* 
Decipher the data
    0x0000000000000000000000000000000000000000000000000000000000000001
    0000000000000000000000000000000000000000000000000000000063229322,
    
    0x0000000000000000000000000000000000000000000000000000000000000002
    0000000000000000000000000000000000000000000000000000000063229322
*/
