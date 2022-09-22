// SPDX-License-Identifier: MIT
pragma solidity >0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("My Token", "TKN") {}

    //
}

interface ExchangeA {
    function priceForToken(address token) external view returns (uint256);

    function enterTrade(address token, uint256 amount)
        external
        returns (uint256);
}

interface ExchangeB {
    function priceForToken(address token) external view returns (uint256);

    function enterTrade(address token, uint256 amount)
        external
        returns (uint256);
}

contract Adapter {
    ExchangeA exchangeA;
    ExchangeB exchangeB;

    constructor(address _exchangeA, address _exchangeB) public {
        exchangeA = ExchangeA(_exchangeA);
        exchangeB = ExchangeB(_exchangeB);
    }

    function getBestExchangeFor(address token) external view returns (address) {
        uint256 priceA = exchangeA.priceForToken(token);
        uint256 priceB = exchangeB.priceForToken(token);
        return priceA > priceB ? address(exchangeB) : address(exchangeA);
    }

    function invest(
        uint256 _amount,
        address _token,
        address _exchange
    ) external {
        if (_exchange == address(exchangeA)) {
            exchangeA.enterTrade(_token, _amount);
        } else {
            exchangeB.enterTrade(_token, _amount);
        }
    }
}

contract MyContract {
    Adapter adapter;
    Token token;

    constructor(address _token) {
        token = Token(_token);
    }

    function updateAdapter(address _adapterAddress) external {
        adapter = Adapter(_adapterAddress);
    }

    function invest(uint256 _amount) external {
        token.approve(address(adapter), _amount);
        address bestExchange = adapter.getBestExahangeFor(address(token));
        adapter.invest(_amount, address(token), bestExchange);
    }
}
