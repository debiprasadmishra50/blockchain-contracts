// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

interface IERC20 {
    function balanceOf(address addr) external view returns (uint256);

    function transfer(address _to, uint256 _amount)
        external
        returns (bool success);

    function transferFrom(
        address sender,
        address receipient,
        uint256 _amount
    ) external returns (bool success);

    function approve(address _spender, uint256 _amount)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _amount);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount
    );
}
