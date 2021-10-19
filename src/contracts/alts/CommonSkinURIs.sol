pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/utils/Strings.sol";
import "../dependencies/Base64.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./CommonSummonerSkins.sol";

// credits to Luchadores NFTs for most of the code https://etherscan.io/address/0x8b4616926705Fb61E9C4eeAc07cd946a5D4b0760#code

// svg logic had to be put in a separate contract to fit in contract size limit.
// This has no impact on gas because the only exposed function is only meant for call
contract CommonSkinURIs is Ownable {
    using Strings for uint256;

	// 0 : accessories
	// 1 : weapons
	// 2 : heads
	// 3 : shoes
	// 4 : torsos
	// 5 : base colors
	// 6 : alt colors
	// 7 : skin colors
	// 8 : alt parts
	// 9 : color parts
	// 10: shadow parts
	// 11: base parts
	mapping(uint => mapping(uint => string)) art;

	string[][5] traitName;
	CommonSummonerSkins immutable skins;

	string constant altPartForBardClericAndDruid = '<path d="M14 20h-1-1-1-1-1v1 1 1h1 1v-1h1 1 1 1v-1-1h-1z"/>';
	string constant shadowPartForSorcererAndWizard = '<path d="M14 19v1 1 1h1v-1-1-1-1-1h-1v1 1zm-4-2h1v1h-1z"/><path d="M9 18h1v1H9zm0-3h1v1H9zm5-3h1v1h-1zm-7-1h1v1H7z"/><path d="M8 10h1v1H8zm3 3v-1h-1-1v1 1h1v-1h1z"/><path d="M13 14v1 1 1h1v-1-1-1-1h-1v1zm-2 0h-1v1h1v1 1h1v-1-1-1-1h-1v1zm4 0h1v1h-1zm0-3h1v1h-1zm-8 7h1v1H7z"/><path d="M7 16v-1-1-1-1H6v1 1 1 1 1 1h1v-1-1zm1 4v1h1v-1-1H8v1z"/><path d="M7 22v1 1h1 1v-1H8v-1-1H7v1z"/>';

    constructor() {
		skins = CommonSummonerSkins(msg.sender);

		traitName[0] = ["Bracelet","Earring","Gloves","Necklace","Ring"];
		traitName[1] = ["Bow","Dagger","Fireball","Halberd","Hatchet","Katana","Knives","Spear","Sword","Wand"];
		traitName[2] = ["Eye Patch","Hat","Headband","Horned","Knight","White Eyes"];
		traitName[3] = ["Big Shoes","Sandals","Shoes","Winged Shoes"];
		traitName[4] = ["Armor","Backpack","Beard","Cape","Satchel","Scabbard","Scarf"];
    }
    
	function tokenURI(uint256 _tokenId, uint256 _dna) external view returns (string memory) {
		return string(abi.encodePacked('data:application/json;base64,',Base64.encode(bytes(metadata(_tokenId,_dna)))));
	}

	function initializeArt(uint startIndex, string[][] calldata data) public onlyOwner {
		for(uint i = 0; i < data.length; i++){
			for(uint j = 0; j < data[i].length; j++){
				art[startIndex + i][j] = data[i][j];
			}
		}
	}
	
	// private funcs
	
	function metadata(uint256 _tokenId, uint256 _dna) private view returns (string memory) {
		uint8[8] memory dna = splitNumber(_dna);

		string memory attributes;

		string[5] memory traitType = ["Accessory","Weapon","Head","Shoes","Torso"];

		for (uint256 i = 0; i < 5; i++) {
			if (bytes(art[i][dna[i]]).length > 0){
				attributes = string(abi.encodePacked(
					attributes, bytes(attributes).length == 0 ? '{' : ', {',
					'"trait_type": "', traitType[i],'",',
					'"value": "', traitName[i][dna[i]], '"',
				'}'));
			}
		}

		return string(abi.encodePacked(
			'{',
				'"name": "Common Skin #', _tokenId.toString(), '",', 
				'"description": "Common Skins are randomly generated and have 100% on-chain art and metadata - Use them as your Summoner appearences !",',
				'"image": "data:image/svg+xml;base64,', Base64.encode(imageData(_tokenId, _dna)), '",',
				'"attributes": [', attributes, ']',
			'}'
		));
	}
	
	function imageData(uint256 _tokenId, uint256 _dna) private view returns (bytes memory) {
		uint8[8] memory dna = splitNumber(_dna);
		uint class = skins.class(_tokenId) - 1;

		string memory skinOfRanger = class == 7 || class == 1 ? string(abi.encodePacked('<path d="M15.99 11v-1h1V9h-1V5h-1V4h-1V3h-4v1h-1v1h-1v5h1v1h1v2h-1-1-1v1 1 1h1v2h2v1h-1v5h1 5 1v-1h-1v-5h1v-1h1v-2h-1v-1-1h-1v-2h1z" fill="#',art[7][dna[7]],'"/>')) : '';

		return abi.encodePacked(
			"<svg id='Common Skin #", _tokenId.toString(), "' xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'>",
				'<path fill="#',art[7][dna[7]],'" d="M16 11v-1h1V9h-1V5h-1V4h-1V3h-4v1H9v1H8v5h1v1h1v4H8v3h2v1H9v5h1 5 1v-1h-1v-5h1v-1h1v-2h-2v-4h1z"/>', // skin
				skinOfRanger,
				'<path d="M12 7h1v1h-1zm3 0h1v1h-1z" fill="#fff"/>', // base eyes
				'<g fill="#',art[6][dna[6]],'">', // alt color
					art[8][class], // alt part
				'</g>',
				'<g fill="#',art[5][dna[5]],'">', // base color
					art[9][class], // color part
				"</g>",
				"<g opacity='.23'>",
					art[10][class], // shadow part
				"</g>",
				art[11][class], // base part
				accessoriesSvg(dna),
			"</svg>"
		);
	}

	function accessoriesSvg(uint8[8] memory dna) private view returns (string memory) {
		return(string(abi.encodePacked(
				art[4][dna[4]], // torso
				art[2][dna[2]], // head
				art[0][dna[0]], // accessory
				art[3][dna[3]], // shoes
				art[1][dna[1]]))); // weapon
	}
	
	// utils
	
	function splitNumber(uint256 _number) internal pure returns (uint8[8] memory) {
		uint8[8] memory numbers;
		
		numbers[0] = uint8(_number % 10); // accessory 1/2
		_number /= 10;
		numbers[1] = uint8(_number % 14); // weapon 5/7
		_number /= 14;
		numbers[2] = uint8(_number % 12); // head 1/2
		_number /= 12;
		numbers[3] = uint8(_number % 8); // shoes 1/2
		_number /= 8;
		numbers[4] = uint8(_number % 16); // torsos 7/16
		_number /= 16;

		for (uint256 i = 5; i < numbers.length; i++) {
			numbers[i] = uint8(_number % 10);
			_number /= 10;
		}

		return numbers;
	}
}