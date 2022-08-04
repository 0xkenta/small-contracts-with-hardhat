//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

error NoPermission();

contract TestNewNft is ERC721, Ownable, Pausable {
    address migrator;

    constructor(address _migrator) ERC721("NEW", "NEW") {
        migrator = _migrator;
    }

    function mint(address _recipient, uint256 _tokenId) external whenNotPaused {
        if (msg.sender != owner() && msg.sender != migrator)
            revert NoPermission();

        _mint(_recipient, _tokenId);
    }

    function pause() external onlyOwner {
        _pause();
    }
}
