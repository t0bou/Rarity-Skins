# Rarity Skins

Provides an open registry for players of Rarity Manifested to link a NFT as skin for their summoner, and twos collections of skins.  

## Usage 

### find the skin of a summoner :

1. call the `skinOf(uint256 summonerId)` method of Rarity Skin Manager  
2. this returns an array `[address, uint256]` with the `address` being the NFT contract, `uint256` being the tokenId of the skin in this contract

### display a skin in your UI

with `skinJson` returned by `tokenURI(uint256 _tokenId)` of the skin NFT contract :

    skinJson = decodeURI(skinBase64)
    skinJson = skinJson.split("data:application/json;base64,").pop()
    skinJson = JSON.parse(Buffer.from(skinJson,"base64").toString())
    imgUri = skinJson.image

    <img src={imgUri}/>


## Contracts

Rarity Skin Manager : https://ftmscan.com/address/0xd1447fe5e70d58204946d61224643738ba54f5cc  

Rare Skins : https://ftmscan.com/address/0x6fed400da17f2678c450aa1d35e909653b3b482a