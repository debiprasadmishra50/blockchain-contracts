// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Color is ERC721 {
    address private _owner;
    string[] public colors;
    mapping(string => bool) private _doesExist;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {
        _owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "not owner");
        _;
    }

    function mint(string memory _color) external onlyOwner {
        // require unique color
        require(!_doesExist[_color], "color exists");
        // track the color and add it
        colors.push(_color);
        // call mint function
        _mint(msg.sender, colors.length);

        _doesExist[_color] = true;
    }

    function totalSupply() external view returns (uint) {
        return colors.length;
    }
}
