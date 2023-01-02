// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// contract Test {
//     event Log(string func, address sender, uint256 value, bytes data);

//     // fallback() external {}
//     fallback() external payable {
//         emit Log("fallback", msg.sender, msg.value, msg.data);
//     } // to send ether

//     // receive is executed when the data that was sent is empty
//     receive() external payable {
//         emit Log("receive", msg.sender, msg.value, "");
//     }
// }

// /*
//     Deploy this contract and send ether to this address.
// */
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface Price {
    function getLatestPrice() external view returns (uint256);
}

contract Demo is ERC20 {
    event Mint(address indexed to, uint indexed value, uint timestamp);
    event Treasury(uint indexed value, uint timestamp);

    uint public immutable rate = 1;
    Price price;

    constructor(Price _priceFeed) public ERC20("RI token", "RIT") {
        price = _priceFeed;
    }

    function decimals() public view override returns (uint8) {
        return 8;
    }

    function mint() external payable {
        require(msg.value > 0, "insufficient funds sent");

        uint latestPrice = price.getLatestPrice();

        uint sentToTreasuryValue = (msg.value * 5) / 100;
        payable(address(this)).transfer(sentToTreasuryValue); // send 5% of ETH to treasury
        emit Treasury(sentToTreasuryValue, block.timestamp);

        uint toMint = msg.value - sentToTreasuryValue;
        uint curValue = toMint * latestPrice; // 8
        uint mintingValue = (curValue * 10**decimals()) / 10**26;

        _mint(msg.sender, mintingValue); // mint 95% token for user

        emit Mint(msg.sender, curValue, block.timestamp);
    }
}
