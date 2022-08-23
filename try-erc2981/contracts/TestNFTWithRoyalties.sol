pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC2981.sol";

contract TestNFTWithRoyalties is ERC721, ERC2981, Ownable {
    uint256 public tokenId = 1;

    constructor() ERC721("Test erc2981", "TERC2981") {}

    function mint(
        address to,
        address royaltyRecipient,
        uint256 royaltyValue
    ) external {
        uint256 _tokenId = tokenId;
        _safeMint(to, _tokenId, "");

        if (royaltyValue > 0) {
            _setTokenRoyalty(_tokenId, royaltyRecipient, royaltyValue);
        }

        tokenId += 1;
    }

    function supportsInterface(bytes4 _interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(_interfaceId);
    }
}
