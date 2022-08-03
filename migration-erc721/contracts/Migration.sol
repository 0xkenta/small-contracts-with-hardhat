//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./test/ITestERC721.sol";

error NotOwner();

contract Migration is ERC721Holder {
    ITestERC721 oldContract;
    ITestERC721 newContract;

    event TokenMigrated();

    constructor(address _oldContract, address _newContract) {
        oldContract = ITestERC721(_oldContract);
        newContract = ITestERC721(_newContract);
    }

    function migrate(uint256 _tokenId) external {
        if (msg.sender != oldContract.ownerOf(_tokenId)) revert NotOwner();

        oldContract.safeTransferFrom(msg.sender, address(this), _tokenId);

        newContract.mint(msg.sender, _tokenId);

        emit TokenMigrated();
    }
}