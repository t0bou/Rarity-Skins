pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "./RaritySkinManager.sol";

// IMPORTANT BUG FIX : use this contract for calls and assignations instead of the original contract.
// Skins assigned using the original contract are still here.

// this contract fixes a bug is rarity skin manager which makes the assignation of
// a NFT not implementing the isStrictOnSummonerClass() method revert.
// It is essentially a wrapper of the original contract, no modification is needed on the
// way to interact with it, besides using his address instead of the original one.
contract RaritySkinManagerFix is Ownable {
    
    address constant rarity = 0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb;

    // original contract
    RaritySkinManager constant exManager = RaritySkinManager(0xd1447FE5e70d58204946D61224643738bA54F5cc);

    address constant deadAddress = 0x000000000000000000000000000000000000dEaD;

    mapping(uint256 => RaritySkinManager.Skin) private _skinOf;
    mapping(bytes32 => uint256) private _summonerOf;
    mapping(address => bool) private trustedImplementations;

    event SumonnerSkinAssigned (RaritySkinManager.Skin skin, uint256 summoner);

    bool constant public isStrictOnSummonerClass = true; // make a function with this
    
    modifier classChecked(address implementation, uint tokenId, uint summonerId) {
        try myIERC721(implementation).isStrictOnSummonerClass() returns(bool isStrict) {
            if(isStrict){
                require(myIERC721(rarity).class(summonerId) == myIERC721(implementation).class(tokenId), "Summoner and skin must be of the same class");
            }

            _;
        } catch Error(string memory){
            _;
        } catch Panic(uint) {
            _;
        } catch (bytes memory) {
            _;
        }
    }

    function skinOf(uint256 summonerId) public view returns(RaritySkinManager.Skin memory){
        (address skinImplemFromExManager, uint skinIdFromExManager) = exManager.skinOf(summonerId);
        RaritySkinManager.Skin memory skin = _skinOf[summonerId];

        if (skin.implementation == deadAddress){
            return RaritySkinManager.Skin(address(0),0);
        }
        else if (skin.implementation == address(0)){
            return RaritySkinManager.Skin(skinImplemFromExManager, skinIdFromExManager);
        } else {
            return _skinOf[summonerId];
        }
    }

    function summonerOf(bytes32 _skinKey) public view returns(uint256 summonerId){
        if (_summonerOf[_skinKey] == 0){
            return exManager.summonerOf(_skinKey);
        } else {
            return _summonerOf[_skinKey];
        }
    }

    // you can request the owner of this contract to add your NFT contract to the trusted list if you implement ownership checks on summoner and token
    function trustedAssignSkinToSummoner(uint tokenId, uint summonerId) external
    classChecked(msg.sender, tokenId, summonerId) {
        require(trustedImplementations[msg.sender], "Only trusted ERC721 implementations can access this way of assignation");
        
        _assignSkinToSummoner(msg.sender, tokenId, summonerId);
    }
    
    function assignSkinToSummoner(address implementation, uint tokenId, uint summonerId) external 
    classChecked(implementation, tokenId, summonerId) {
        require(isApprovedOrOwner(implementation, msg.sender, tokenId), "You must be owner or approved for this token");
        require(isApprovedOrOwner(rarity, msg.sender, summonerId), "You must be owner or approved for this summoner");
        
        _assignSkinToSummoner(implementation, tokenId, summonerId);
    }

    function _assignSkinToSummoner(address implementation, uint tokenId, uint summonerId) private {
        // reinitialize previous assignation
        _skinOf[_summonerOf[exManager.skinKey(RaritySkinManager.Skin(implementation, tokenId))]] = RaritySkinManager.Skin(deadAddress,0);
        
        _summonerOf[exManager.skinKey(RaritySkinManager.Skin(implementation, tokenId))] = summonerId;
        _skinOf[summonerId] = RaritySkinManager.Skin(implementation, tokenId);
        
        emit SumonnerSkinAssigned(RaritySkinManager.Skin(implementation, tokenId), summonerId);
    }

    function skinKey(RaritySkinManager.Skin memory skin) public pure returns(bytes32) {
        return exManager.skinKey(skin);
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