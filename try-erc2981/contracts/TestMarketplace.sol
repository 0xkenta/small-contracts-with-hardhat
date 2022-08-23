pragma solidity 0.8.9;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/utils/ERC721HolderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/IERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/structs/EnumerableSetUpgradeable.sol";
import "./IERC2981.sol";

contract TestMarketplace is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    ERC721HolderUpgradeable
{
    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    struct Ask {
        address seller; // the nft owner
        uint256 askPrice; // in wei
    }

    /// NFT address => token Id => Ask
    mapping(address => mapping(uint256 => Ask)) public asks;
    /// NFT address => token Ids
    mapping(address => EnumerableSetUpgradeable.UintSet) private tokenIdsPerNft;
    /// seller address => nft address => token Ids
    mapping(address => bool) public transactableNfts;

    event NewAskCreated(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address indexed currentOwner,
        uint256 newAskPrice
    );

    event NftSold(
        address indexed nftAddress,
        uint256 indexed tokenId,
        address seller,
        address newOwner,
        uint256 buyPrice
    );
    event TransactableNftUpdated(address _nftAddress, bool _isTransactable);

    /// @notice initialize this contract with libraries.
    function initialize() public initializer {
        /// intialize libraries
        __Ownable_init();
        __ReentrancyGuard_init();
        __Pausable_init();
        __ERC721Holder_init();
    }

    /// @notice a token owner can create an Ask and try to sell the token
    /// @param _nftAddress the address of the nft contract
    /// @param _tokenId the token id that the owner wants to sell
    /// @param _askPrice the price that the token owner wants to have from the sale
    function createAsk(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _askPrice
    ) external whenNotPaused nonReentrant {
        // TODO!!! validation for the _askPrice

        require(transactableNfts[_nftAddress], "INVALID NFT ADDRESS");
        require(
            IERC721Upgradeable(_nftAddress).ownerOf(_tokenId) == msg.sender,
            "YOU DO NOT HAVE THIS NFT"
        );
        require(
            IERC721Upgradeable(_nftAddress).isApprovedForAll(
                msg.sender,
                address(this)
            ) ||
                IERC721Upgradeable(_nftAddress).getApproved(_tokenId) ==
                address(this),
            "NO APPROVEMENT FOR THIS TOKEN"
        );

        IERC721Upgradeable(_nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _tokenId
        );

        asks[_nftAddress][_tokenId] = Ask({
            seller: msg.sender,
            askPrice: _askPrice
        });
        tokenIdsPerNft[_nftAddress].add(_tokenId);

        emit NewAskCreated(_nftAddress, _tokenId, msg.sender, _askPrice);
    }

    function buyNft(address _nftAddress, uint256 _tokenId)
        external
        payable
        whenNotPaused
        nonReentrant
    {
        require(
            tokenIdsPerNft[_nftAddress].contains(_tokenId),
            "THIS TOKEN IS NOT FOR SALE"
        );

        Ask memory _ask = asks[_nftAddress][_tokenId];

        require(msg.sender != _ask.seller, "SELF TRANSACTION IS NOT ALLOWED");
        require(msg.value == _ask.askPrice, "INVALID PRICE");

        delete asks[_nftAddress][_tokenId];
        tokenIdsPerNft[_nftAddress].remove(_tokenId);

        (address receiver, uint256 royaltyAmount) = IERC2981(_nftAddress)
            .royaltyInfo(_tokenId, _ask.askPrice);

        uint256 payoutToSeller = _ask.askPrice - royaltyAmount;

        transferETH(_ask.seller, payoutToSeller);
        transferETH(receiver, royaltyAmount);

        IERC721Upgradeable(_nftAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        emit NftSold(_nftAddress, _tokenId, _ask.seller, msg.sender, msg.value);
    }

    function transferETH(address _recipient, uint256 _amount) internal {
        (bool success, ) = _recipient.call{value: _amount}("");
        require(success, "Failed to send");
    }

    function updateTransactableNft(address _nftAddress, bool _isTransactable)
        external
        onlyOwner
    {
        transactableNfts[_nftAddress] = _isTransactable;
        emit TransactableNftUpdated(_nftAddress, _isTransactable);
    }
}
