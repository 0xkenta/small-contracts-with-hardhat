// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;

import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";


contract TestERC721a is ERC721AQueryable, ERC2981, AccessControlEnumerable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 public maxSupplyPerDay;

    constructor(uint256 _maxSupplyPerDay) ERC721A("test", "TEST") {
        maxSupplyPerDay = _maxSupplyPerDay;

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(BURNER_ROLE, _msgSender());
    }

    function mint(address _to, uint256 _quantity) external onlyRole(MINTER_ROLE) {
        _safeMint(_to, _quantity);
    }

    function burn(uint256[] calldata tokenIds) external onlyRole(BURNER_ROLE) {
        for (uint256 i; i < tokenIds.length;) {
            _burn(tokenIds[i]);
            unchecked {
                ++i;
            }
        }
    }

    function setRoyalty(address _receiver, uint96 _feeNumerator) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        return "ipfs://KIICHI";
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981, AccessControlEnumerable) returns (bool) {
    return 
        ERC721A.supportsInterface(interfaceId) || 
        ERC2981.supportsInterface(interfaceId);
    }
}
