// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUniRouter02 {
    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function WETH() external pure returns (address);
}

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

contract DeFIUniswapV2 {
    IUniRouter02 uniswap;

    constructor(address _uniswap) {
        uniswap = IUniRouter02(_uniswap);
    }

    // _token to spend
    // amount of _token you want to spend
    // min out you expect in return
    // deadline for the validity of the transaction
    function swapTokensForETH(
        address _token,
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external {
        IERC20(_token).transferFrom(msg.sender, address(this), amountIn);

        address[] memory path = new address[](2);
        path[0] = _token;
        path[1] = uniswap.WETH();

        IERC20(_token).approve(address(uniswap), amountIn);

        uniswap.swapExactTokensForETH(
            amountIn,
            amountOutMin,
            path,
            msg.sender,
            deadline
        );
    }
}
