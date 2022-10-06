// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

/* 
    seller sets the price at the start of the auction, and the price goes down over time, when the buer decides the price is low enough, then he buys and the auction ends

    Auction
        Seller of NFT deploys this contract setting a starting price for the NFT.
        Auction lasts for 7 days.
        Price of NFT decreases over time.
        Participants can buy by depositing ETH greater than the current price computed by the smart contract.
        Auction ends when a buyer buys the NFT.
*/

interface IERC721 {
    function transferFrom(address _from, address _to, uint _nftId) external;
}

contract DutchAuction {
    uint private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint public immutable nftId;

    address payable public immutable seller;
    uint public immutable startingPrice;
    uint public immutable startsAt;
    uint public immutable expiresAt;
    uint public immutable discountRate;

    constructor (uint _startingPrice, uint _discountRate, address _nft, uint _nftId) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startsAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(_startingPrice >= _discountRate * DURATION, "starting price is less than discount");

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint) {
        uint timeElapsed = block.timestamp - startsAt;
        uint discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");
        
        uint price = getPrice();
        require(msg.value >= price, "ETH < price");

        nft.transferFrom(seller, msg.sender, nftId);

        uint refund = msg.value - price;
        if (refund > 0)
            payable(msg.sender).transfer(refund);

        selfdestruct(seller);    
    }
}


