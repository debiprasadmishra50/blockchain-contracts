// SPDX-License-Identifier: MIT
pragma solidity >0.5.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

contract DutchAuction {}
