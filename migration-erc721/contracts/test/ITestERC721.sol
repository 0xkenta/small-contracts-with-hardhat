//SPDX-License-Identifier: Unlicense
pragma solidity 0.8.9;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface ITestERC721 is IERC721 {
    function mint(address _recipient, uint256 _tokenId) external;
}
