// SPDX-License-Identifier: The Unlicense
pragma solidity 0.8.15;

import {ERC721Enumerable, ERC721} from "openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC2981} from "openzeppelin/token/common/ERC2981.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";

contract AltoERC721Individual is
    Ownable,
    ERC2981,
    ERC721Enumerable
 {

    mapping(uint256 => string) private _tokenURIs;

    uint256 immutable individualFee;
    
    constructor(
        uint256 _individualFee
    ) ERC721(
        "Alto Common Collection", "ALTO"
    ){
        individualFee = _individualFee;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, ERC2981) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function mintNext(string memory uri, address receiver, uint96 feeNumerator) external payable {
        require(msg.value >= individualFee, "insufficient fee");

        uint nextId = totalSupply();
        _mint(msg.sender, nextId);
        _tokenURIs[nextId] = uri;
        _setTokenRoyalty(
            nextId,
            receiver,
            feeNumerator
        );
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

}

contract AltoERC721CommonFactory is Ownable {

    uint256 individualPrice;

    constructor(
        uint256 _individualPrice
    ) {
        individualPrice = _individualPrice;
    }

    function createCommonCollection() external onlyOwner returns (address collection) {
        collection = address(new AltoERC721Individual(individualPrice));
    }

    // Admin Functions

    // send all funds held here to owner
    function withdrawFunds() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    function updateCollectionFee(
        uint256 newFeeIndividual
    ) external onlyOwner {
        individualPrice = newFeeIndividual;
    }

}