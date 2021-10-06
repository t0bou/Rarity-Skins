pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

interface myIERC721 {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    
    // want to implement an ERC721 that can be used as skin only for the intended class ?
    // vvv expose those two functions vvv
    function isStrictOnSummonerClass() external returns (bool);
    function class(uint) external returns (uint);
}

// gift to the community : open standard to use any ERC721 as summoner skin !
contract RaritySkinManager is Ownable {
    
    address constant rarity = 0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb;
    
    mapping(uint256 => Skin) public skinOf;
    mapping(bytes32 => uint256) public summonerOf;
    mapping(address => bool) private trustedImplementations;
    
    event SumonnerSkinAssigned (Skin skin, uint256 summoner);
    
    struct Skin {
        address implementation;
        uint256 tokenId;
    }
    
    modifier classChecked(address implementation, uint tokenId, uint summonerId) {
        try myIERC721(implementation).isStrictOnSummonerClass() returns(bool isStrict) {
            if(isStrict){
                require(myIERC721(rarity).class(summonerId) == myIERC721(implementation).class(tokenId), "Summoner and skin must be of the same class");
            }

            _;
        } catch Panic(uint) {
            _;
        }
    }
    
    function assignSkinToSummoner(address implementation, uint tokenId, uint summonerId) external 
    classChecked(implementation, tokenId, summonerId) {
        require(isApprovedOrOwner(implementation, msg.sender, tokenId), "You must be owner or approved for this token");
        require(isApprovedOrOwner(rarity, msg.sender, summonerId), "You must be owner or approved for this summoner");
        
        _assignSkinToSummoner(implementation, tokenId, summonerId);
    }

    // you can request the owner of this contract to add your NFT contract to the trusted list if you implement ownership checks on summoner and token
    function trustedAssignSkinToSummoner(uint tokenId, uint summonerId) external
    classChecked(msg.sender, tokenId, summonerId) {
        require(trustedImplementations[msg.sender], "Only trusted ERC721 implementations can access this way of assignation");
        
        _assignSkinToSummoner(msg.sender, tokenId, summonerId);
    }
    
    function _assignSkinToSummoner(address implementation, uint tokenId, uint summonerId) private {
        // reinitialize previous assignation
        skinOf[summonerOf[skinKey(Skin(implementation, tokenId))]] = Skin(address(0),0);
        
        summonerOf[skinKey(Skin(implementation, tokenId))] = summonerId;
        skinOf[summonerId] = Skin(implementation, tokenId);
        
        emit SumonnerSkinAssigned(Skin(implementation, tokenId), summonerId);
    }
    
    function skinKey(Skin memory skin) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(skin.implementation, skin.tokenId));
    }
    
    function trustImplementation(address _impAddress) external onlyOwner {
        trustedImplementations[_impAddress] = true;
    }
    
    function isApprovedOrOwner(address nftAddress, address spender, uint256 tokenId) private view returns (bool) {
        myIERC721 implementation = myIERC721(nftAddress);
        address owner = implementation.ownerOf(tokenId);
        return (spender == owner || implementation.getApproved(tokenId) == spender || implementation.isApprovedForAll(owner, spender));
    }
}