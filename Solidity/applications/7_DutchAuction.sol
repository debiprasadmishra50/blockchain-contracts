// SPDX-License-Identifier: MIT
pragma solidity >0.5.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

/* 
What it is?
    - It is a auction where seller sets a price at the start of the auction and the price goes down over time
    - when the buyer decides the price is low enough and he buys the product, the auction ends
*/

/* 
Deployment Steps:
    1. Deploy the ERC721
    2. call the mint(): account_address and nftId(any random value)
    3. Deploy the DutchAuction
        10000000, 1, nftAddress, nftId
    4. approve function in NFT
        DutchAuction Contract address, nftId
    5. Auction has just started
    6. execute getPrice, few times with time interval
    7. execute buy with another address and sending ETH to it
    8. execute the owner() in ERC721 and verify the address
*/
contract DutchAuction {
    uint256 private constant DURATION = 7 days;

    IERC721 public immutable nft;
    uint256 public immutable nftId;

    address payable public immutable seller;
    uint256 public immutable startingPrice;

    uint256 public immutable startedAt;
    uint256 public immutable expiresAt;

    uint256 public immutable discountRate;

    constructor(
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nft,
        uint256 _nftId
    ) {
        seller = payable(msg.sender);
        startingPrice = _startingPrice;
        discountRate = _discountRate;
        startedAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;

        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price < discount"
        ); // max amount ofdeduction applied to a starting price

        nft = IERC721(_nft);
        nftId = _nftId;
    }

    /* get current price of the NFT */
    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startedAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        // check if the auction is still live
        require(block.timestamp < expiresAt, "auction expired");

        // check if the ETH sent is > nft's current price
        uint256 curPrice = getPrice();
        require(msg.value >= curPrice, "ETH < price");

        // transfer the nft ownership
        nft.transferFrom(seller, msg.sender, nftId);

        // refund the extra amount
        uint256 refund = msg.value - curPrice;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }

        selfdestruct(seller); // closes the auction
    }
}
