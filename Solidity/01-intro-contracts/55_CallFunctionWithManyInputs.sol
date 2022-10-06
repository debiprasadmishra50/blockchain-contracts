// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

contract CallFunctionWithManyInputs {
    function callFunctionWithManyInputs(
        uint256 x,
        uint256 y,
        uint256 z,
        address a,
        bool b,
        string memory str
    ) public pure returns (uint256) {}

    /* With this, we no longer have to worry about the order of function arguments */
    function callFuncWithKeyValues() external pure returns (uint256) {
        return
            callFunctionWithManyInputs({
                x: 1,
                y: 2,
                z: 3,
                a: address(0),
                b: true,
                str: "ABC"
            });
    }
}
