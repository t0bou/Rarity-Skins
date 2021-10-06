pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./RaritySkinManager.sol";
import "./SkinURIs.sol";

interface Rarity {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function class(uint) external returns (uint);
}

contract SummonerSkins is ReentrancyGuard, Ownable, ERC721Enumerable {
    using Counters for Counters.Counter;
	
    Counters.Counter private _tokenIds;

	Rarity constant rarity = Rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
	SkinURIs immutable skinURIs;
	RaritySkinManager public raritySkinManager;
	
	// config
	uint constant maxSupply = 5000;
	uint constant startingPrice = 5 ether;
	uint constant auctionDuration = 4 days;
	bool constant public isStrictOnSummonerClass = true;
	uint minimumPrice = 1 ether;
	
	uint immutable startDate;

    mapping(uint256 => uint) skinDNA;
    mapping(uint => uint) public class;
    
    constructor() ERC721("Summoner Rare Skins", "RARE SKINS"){
		startDate = block.timestamp;
		skinURIs = new SkinURIs(maxSupply);
		raritySkinManager = new RaritySkinManager();
		raritySkinManager.trustImplementation(address(this));
		raritySkinManager.transferOwnership(msg.sender);
	}
	
	// Minting logic
	
	function getPrice() public view returns(uint){ // Dutch Auction
	    return ( block.timestamp < startDate + auctionDuration ?
	            max((startingPrice / auctionDuration) * ((startDate + auctionDuration) - block.timestamp), minimumPrice)
	        :
	            minimumPrice);
	}
	
	function max(uint a, uint b) private pure returns(uint){
	    return a > b ? a : b;
	}
	
	modifier supplyAndPriceAreSufficient(uint quantity) {
	    require(_tokenIds.current() < maxSupply, "maximum skins reached");
		require(_tokenIds.current() + quantity <= maxSupply, "mint quantity exceeds max supply");
		require(msg.value >= getPrice() * quantity, "the FTM transfer amount is under the price");
	    
	    _;
	}
	
	function mint(uint quantity) external payable nonReentrant supplyAndPriceAreSufficient(quantity) { // mint random classes
	    uint randomClass = randomUint(_tokenIds.current()) % 11;
	    
	    for(uint i = 0; i < quantity; i++){
	        _mintOneSkin(((randomClass + i) % 11) + 1);
	    }
	}
	
	function mintAndAssign(uint256[] memory summonerIds) external payable nonReentrant supplyAndPriceAreSufficient(summonerIds.length) { // mint and assign
		for(uint i = 0; i < summonerIds.length; i++){
            require(_isApprovedOrOwnerInRarity(summonerIds[i]), "You must be owner or approved for this summoner");
		    
		    raritySkinManager.trustedAssignSkinToSummoner(_mintOneSkin(rarity.class(summonerIds[i])), summonerIds[i]);
		}
	}

	function _mintOneSkin(uint _class) private returns(uint skinId) {
        uint random = randomUint(_tokenIds.current());
        
        _tokenIds.increment();
        _safeMint(msg.sender, _tokenIds.current());
        skinDNA[_tokenIds.current()] = random;
        class[_tokenIds.current()] = _class;
        
        // no emit here : openzeppelin's ERC721 implementation already emits a 'mint' event
        
        return(_tokenIds.current());
    }
    
    // URI
	
	function tokenURI(uint256 _tokenId) public override view returns (string memory) {
	    require(_exists(_tokenId), "tokenURI: nonexistent token");
	    
	    return skinURIs.tokenURI(_tokenId, skinDNA[_tokenId]);
	}
	
	// admin actions
	
	function withdraw() public onlyOwner {
		(bool success, ) = msg.sender.call{value: address(this).balance}('');
		require(success, "Withdrawal failed");
	}
	
	function setMinimumPrice(uint _minimumPrice) public onlyOwner {
	    minimumPrice = _minimumPrice;
	}
	
	// utils
	
	function randomUint(uint id) private view returns(uint) {
	    return(uint(keccak256(abi.encodePacked(blockhash(block.number - 1), id))));
	}
	
	function _isApprovedOrOwnerInRarity(uint summonerId) private view returns(bool){
	    address owner = rarity.ownerOf(summonerId);
        return (msg.sender == owner || rarity.getApproved(summonerId) == msg.sender || rarity.isApprovedForAll(owner, msg.sender));
	}
}