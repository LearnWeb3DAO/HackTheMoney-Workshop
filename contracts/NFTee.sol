// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract NFTee is ERC721 {
    uint256 public immutable MAX_NFTS;
    uint256 tokenIdCounter;

    constructor(uint256 maxNfts) ERC721("NFTee", "NFTEE") {
        MAX_NFTS = maxNfts;
    }

    function freeMint() public {
        require(tokenIdCounter < MAX_NFTS, "MAX_SUPPLY_REACHED");
        tokenIdCounter++;
        _safeMint(msg.sender, tokenIdCounter);
    }
}
