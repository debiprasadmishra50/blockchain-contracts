// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFT is ERC721URIStorage {
    uint public tokenCount = 0;

    constructor() ERC721("Debi NFT", "DPM") {}

    function mint(string memory _tokenURI) external returns (uint) {
        tokenCount += 1;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);

        return tokenCount;
    }
}
