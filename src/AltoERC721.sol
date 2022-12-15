// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.15;

import {ERC721Enumerable, ERC721} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC2981} from "openzeppelin/token/common/ERC2981.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract AltoERC721Collection_1_of_1 is
    Ownable,
    ERC2981,
    ERC721Enumerable
 {

    mapping(uint256 => string) private _tokenURIs;
    
    constructor(
        address _owner,
        address _receiver, 
        uint96 _feeNumerator,
        string memory _name,
        string memory _symbol
    ) ERC721(
        _name, _symbol
    ){
        _setDefaultRoyalty(_receiver, _feeNumerator);
        _transferOwnership(_owner);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mintNext(string memory uri) external onlyOwner {
        uint nextId = totalSupply();
        _mint(msg.sender, nextId);
        _tokenURIs[nextId] = uri;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireMinted(tokenId);

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    function updateDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setIndividualRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) external onlyOwner {
        _setTokenRoyalty(
            tokenId,
            receiver,
            feeNumerator
        );
    }

}

contract AltoERC721CollectionBase is
    Ownable,
    ERC2981,
    ERC721Enumerable
 {

    string baseUri;
    uint256 immutable mintFee;
    uint256 immutable maxSupply;
    uint256 immutable mintLimit;
    
    constructor(
        address _owner,
        address _receiver, 
        uint96 _feeNumerator,
        string memory _name,
        string memory _symbol,
        string memory _uriBase, 
        uint256 _mintFee,
        uint256 _maxSupply,
        uint256 _mintLimit
    ) ERC721(
        _name, _symbol
    ){
        _setDefaultRoyalty(_receiver, _feeNumerator);
        _transferOwnership(_owner);
        baseUri = _uriBase;
        mintFee = _mintFee;
        maxSupply = _maxSupply;
        mintLimit = _mintLimit;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mint(uint256 amount) external payable {
        require(totalSupply()+amount <= maxSupply, "Mint Completed");
        require(msg.value >= mintFee * amount, "Insufficient Payment");
        require(amount <= mintLimit, "Exceeds max mint");

        for(uint256 i = 0; i<amount; i++){
            uint nextId = totalSupply();
            _mint(msg.sender, nextId);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return baseUri;
    }

    function updateBaseURI(string memory newUri) public onlyOwner {
        baseUri = newUri;
    }

    function updateDefaultRoyalty(address receiver, uint96 feeNumerator) external onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function setIndividualRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) external onlyOwner {
        _setTokenRoyalty(
            tokenId,
            receiver,
            feeNumerator
        );
    }

}

contract AltoERC721Factory is Ownable {

    uint256 collectionPrice;
    uint256 oneofOnePrice;
    uint256 individualPrice;

    constructor(
        uint256 _collectionPrice,
        uint256 _oneofOnePrice
    ) {
        collectionPrice = _collectionPrice;
        oneofOnePrice = _oneofOnePrice;
    }

    function createBaseCollection(
        address feeReceiver, 
        uint96 feeNumerator,
        string memory name,
        string memory symbol,
        string memory uriBase, 
        uint256 mintFee,
        uint256 maxSupply,
        uint256 mintSupply
    ) external payable returns (address collection) {
        require(msg.value >= collectionPrice, "Insufficient Payment");

        collection = address(new AltoERC721CollectionBase(msg.sender, feeReceiver, feeNumerator, name, symbol, uriBase, mintFee, maxSupply, mintSupply));

    }

    function create1of1Collection(
        address feeReceiver, 
        uint96 feeNumerator,
        string memory name,
        string memory symbol
    ) external payable returns (address collection) {
        require(msg.value >= oneofOnePrice, "Insufficient Payment");

        collection = address(new AltoERC721Collection_1_of_1(msg.sender, feeReceiver, feeNumerator, name, symbol));
    }

    // Admin Functions

    // send all funds held here to owner
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function updateCollectionFee(
        uint256 newFeeCollection, 
        uint256 newFee1of1
    ) external onlyOwner {
        collectionPrice = newFeeCollection;
        oneofOnePrice = newFee1of1;
    }

}