// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address, uint256) external;
}

contract Token is IERC20 {
    function transfer(address, uint256) external override {}
}

/* 
    1. Deploy Token, AbiEncode
    2. put Token addr and value in func arg and call all three functions
    3. 
*/
contract AbiEncode {
    function test(address _contract, bytes calldata data) external {
        (bool ok, ) = _contract.call(data);
        require(ok, "call failed");
    }

    function encodeWithSignature(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSignature("transfer(address,uint256)", to, amount);
    }

    function encodeWithSelector(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeWithSelector(IERC20.transfer.selector, to, amount);
    }

    function encodeWithCall(address to, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encodeCall(IERC20.transfer, (to, amount));
    }
}
