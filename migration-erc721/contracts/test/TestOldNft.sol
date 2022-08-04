//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

error NoPermission();

contract TestOldNft is ERC721, Ownable, Pausable {
    constructor() ERC721("OLD", "OLD") {}

    function mint(address _recipient, uint256 _tokenId)
        external
        onlyOwner
        whenNotPaused
    {
        _mint(_recipient, _tokenId);
    }

    function pause() external onlyOwner {
        _pause();
    }
}
