//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

error NoPermission();

contract TestNewNft is ERC721Pausable, Ownable {
    address migrator;

    constructor(string memory _name, string memory _symbol, address _migrator) ERC721(_name, _symbol) {
        migrator = _migrator;  
    }

    function mint(address _recipient, uint256 _tokenId) external whenNotPaused {
        if (msg.sender != owner() && msg.sender != migrator) revert NoPermission();

        _mint(_recipient, _tokenId);
    }

    function pause() external onlyOwner {
        _pause();
    }
}