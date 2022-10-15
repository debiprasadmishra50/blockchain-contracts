// https://eips.ethereum.org/EIPS/eip-20
// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IERC20 {
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

contract Token is IERC20 {
    uint256 public totalSupply = 1000000000000000000000000;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowed;
    // Metadata for the token
    string public name = "Debi Prasad Token";
    string public symbol = "DPM";
    uint8 public decimals = 18;

    constructor() public {
        balanceOf[msg.sender] = totalSupply;
    }

    function transfer(address _to, uint256 _amount)
        external
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _amount, "insufficient funds");
        balanceOf[msg.sender] -= _amount;
        balanceOf[_to] += _amount;

        emit Transfer(msg.sender, _to, _amount);
        success = true;
    }

    /* 
        it would transfer some token from sender to recipient for the amount from the input
        - it can be called by anyone as long as sender has approved msg.sender to spend his tokens
    */
    function transferFrom(
        address sender,
        address receipient,
        uint256 _amount
    ) external returns (bool success) {
        uint256 allowanceAmount = allowed[sender][msg.sender];
        require(
            balanceOf[sender] >= _amount && allowanceAmount >= _amount,
            "token balance or allowance amount is lower than amount requested"
        );
        allowed[sender][msg.sender] -= _amount;
        balanceOf[sender] -= _amount;
        balanceOf[receipient] += _amount;

        emit Transfer(sender, receipient, _amount);
        success = true;
    }

    /* 
        msg.sender will be able to approve a spender to spend some of his balance for the amount  
    */
    function approve(address _spender, uint256 _amount)
        external
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);

        success = true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining)
    {
        remaining = allowed[_owner][_spender];
    }

    function mint(uint256 _amount) external {
        balanceOf[msg.sender] += _amount;
        totalSupply += _amount;
        emit Transfer(address(0), msg.sender, _amount);
    }

    function burn(uint256 _amount) external {
        balanceOf[msg.sender] -= _amount;
        totalSupply -= _amount;
        emit Transfer(msg.sender, address(0), _amount);
    }
}
