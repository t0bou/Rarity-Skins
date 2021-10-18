# Rarity Skins

Provides an open registry for players of Rarity Manifested to link a NFT as skin for their summoner, and twos collections of skins.  

## Usage 

### find the skin of a summoner :

1. call the `skinOf(uint256 summonerId)` method of Rarity Skin Manager  
2. this returns an array `[address, uint256]` with the `address` being the NFT contract, `uint256` being the tokenId of the skin in this contract

### display a skin in your UI (can be reused to display any NFT)

with `tokenURI` returned by `tokenURI(uint256 _tokenId)` of the skin NFT contract :

    skinJson = decodeURI(skinBase64)
    skinJson = skinJson.split("data:application/json;base64,").pop()
    skinJson = JSON.parse(Buffer.from(skinJson,"base64").toString())
    imgUri = skinJson.image

    <img src={imgUri}/>


## Contracts

IMPORTANT !! The Skin Manager Address has changed due to a bug fix  
The raritySkinManager() method returned by Rare Skins's contract no longer sends the correct address.  
   
Rarity Skin Manager : https://ftmscan.com/address/0xffdfc7286c2c8d0a94f99c5e00da1851564f8c1d

Rare Skins : https://ftmscan.com/address/0x6fed400da17f2678c450aa1d35e909653b3b482a