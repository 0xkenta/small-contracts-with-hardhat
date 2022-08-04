//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./test/ITestERC721.sol";
import "hardhat/console.sol";

error NoPermission();

contract Migration is ERC721Holder {
    ITestERC721 oldContract;
    ITestERC721 newContract;

    event TokenMigrated();
    event NewContractUpdated(address newContract);

    constructor(address _oldContract) {
        oldContract = ITestERC721(_oldContract);
    }

    function migrate(uint256 _tokenId) external {
        if (msg.sender != oldContract.ownerOf(_tokenId)) revert NoPermission();

        oldContract.safeTransferFrom(msg.sender, address(this), _tokenId);

        newContract.mint(msg.sender, _tokenId);

        emit TokenMigrated();
    }

    function setNewContract(address _newContract) external {
        newContract = ITestERC721(_newContract);

        emit NewContractUpdated(_newContract);
    }
}
