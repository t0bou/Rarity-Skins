pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "./RaritySkinManagerFix.sol";
import "./CommonSkinURIs.sol";

interface Rarity {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function class(uint) external returns (uint);
}

contract CommonSummonerSkins is ReentrancyGuard, Ownable, ERC721Enumerable {
    using Counters for Counters.Counter;
	
    Counters.Counter private _tokenIds;

	Rarity constant rarity = Rarity(0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb);
	CommonSkinURIs public skinURIs;
	RaritySkinManagerFix public constant raritySkinManager = RaritySkinManagerFix(0xfFDFc7286c2c8d0a94f99c5e00dA1851564f8C1d);
	
	// config
	uint public price = 1 ether / 10;
	bool constant public isStrictOnSummonerClass = true;
	
    mapping(uint256 => uint) skinDNA;
    mapping(uint => uint) public class;
    
    constructor() ERC721("Summoner Common Skins", "COMMON SKINS"){
		skinURIs = new CommonSkinURIs();
		skinURIs.transferOwnership(msg.sender);
	}
	
	modifier supplyAndPriceAreSufficient(uint quantity) {
		require(msg.value >= price * quantity, "the FTM transfer amount is under the price");
	    
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
	
	function setPrice(uint _price) public onlyOwner {
	    price = _price;
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