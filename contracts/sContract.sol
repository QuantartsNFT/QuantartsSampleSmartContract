// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

contract MyNFT is ERC721Enumerable, Ownable, IERC2981 {
    uint256 public constant maxSupply = 150;
    uint256 public constant tokenPrice = 30000000000000000; // 0.03 ETH
    uint256 public constant whitelistEndTime = 1658774400; // Timestamp para 25 de Abril de 2022 de cuando acaba la whitelist
    uint256 public constant publicSaleStartTime = 1658860800; // Timestamp para 26 de Abril de 2022 de cuando empieza el mint

    mapping(address => bool) private whitelist;

    struct TokenMetadata {
        string name;
        string imageUrl;
        string coordinates;
    }

    mapping(uint256 => TokenMetadata) private _tokenMetadata;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function addToWhitelist(address[] calldata addresses) external onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            whitelist[addresses[i]] = true;
        }
    }

    function mintNFT(
        string memory name,
        string memory imageUrl,
        string memory coordinates
    ) external payable {
        require(block.timestamp >= whitelistEndTime || whitelist[msg.sender], "Not whitelisted yet");
        require(block.timestamp >= publicSaleStartTime, "Public sale has not started yet");
        require(totalSupply() + 1 <= maxSupply, "Exceeds max supply");
        require(msg.value == tokenPrice, "Incorrect Ether value");

        uint256 tokenId = totalSupply() + 1;

        _mint(msg.sender, tokenId);
        _tokenMetadata[tokenId] = TokenMetadata(name, imageUrl, coordinates);
    }

    function getTokenMetadata(uint256 tokenId)
        external
        view
        returns (TokenMetadata memory)
    {
        return _tokenMetadata[tokenId];
    }

    function royaltyInfo(uint256, uint256 saleAmount)
        external
        view
        override
        returns (address receiver, uint256 royaltyAmount)
    {
        receiver = owner();
        royaltyAmount = (saleAmount * 10) / 100; // 10% royalty
    }
}
