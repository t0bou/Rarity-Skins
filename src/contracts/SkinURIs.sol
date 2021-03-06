pragma solidity >=0.8.0 <0.9.0;
//SPDX-License-Identifier: MIT

import '@openzeppelin/contracts/utils/Strings.sol';
import './dependencies/Base64.sol';
import './SummonerSkins.sol';

// credits to Luchadores NFTs for most of the code https://etherscan.io/address/0x8b4616926705Fb61E9C4eeAc07cd946a5D4b0760#code

// svg logic had to be put in a separate contract to fit in contract size limit.
// This has no impact on gas because the only exposed function is only meant for call
contract SkinURIs {
    using Strings for uint256;
    
    struct Item {
		bytes12 name;
		string svg;
	}
	
	struct Art {
		string[] baseColor;
		string[] altColor;
		string[] skinColor;

		mapping(uint256 => Item) accessory;
		mapping(uint256 => Item) weapon;
		mapping(uint256 => Item) head;
		mapping(uint256 => Item) shoes;
		mapping(uint256 => Item) torso;

		string[] altPart;
		string[] colorPart;
		string[] shadowPart;
		string[] basePart;
	}
	
	Art art;
	uint256 immutable maxSupply;
	SummonerSkins immutable skins;

	string constant altPartForBardClericAndDruid = "<path d='M14 20h-1-1-1-1-1v1 1 1h1 1v-1h1 1 1 1v-1-1h-1z'/>";
	string constant shadowPartForSorcererAndWizard = "<path d='M14 19v1 1 1h1v-1-1-1-1-1h-1v1 1zm-4-2h1v1h-1z'/><path d='M9 18h1v1H9zm0-3h1v1H9zm5-3h1v1h-1zm-7-1h1v1H7z'/><path d='M8 10h1v1H8zm3 3v-1h-1-1v1 1h1v-1h1z'/><path d='M13 14v1 1 1h1v-1-1-1-1h-1v1zm-2 0h-1v1h1v1 1h1v-1-1-1-1h-1v1zm4 0h1v1h-1zm0-3h1v1h-1zm-8 7h1v1H7z'/><path d='M7 16v-1-1-1-1H6v1 1 1 1 1 1h1v-1-1zm1 4v1h1v-1-1H8v1z'/><path d='M7 22v1 1h1 1v-1H8v-1-1H7v1z'/>";

    constructor(uint256 _maxSupply) {
        art.baseColor = ['FFD432', 'F28DB2', 'A2E0E0', 'FFAA98', 'D90B1C', '03258C', 'D2D904', '25C7D9', '7248B5', '8C0327'];
		art.altColor = ['110066', '3386A0', 'BF7B6D', '6B0DFF', '40342F', 'FFE000', '591202', 'E88567', 'DD7F19', '0D7CA3'];
		art.skinColor = ['f9d1b7', 'f7b897', 'f39c77', 'ffcb84', 'bd7e47', 'b97e4b', 'b97a50', '5a3214', '50270e', '3a1b09'];
		
		art.accessory[0] = Item('Bracelet',"<g fill='#ffe922'><path d='M7 16h1v1H7z'/><path d='M8 15h1v1H8z'/><path d='M9 14h1v1H9z'/></g>");
		art.accessory[1] = Item('Earring',"<path d='M8 9h1v1H8z' fill='red'/>");
		art.accessory[2] = Item('Necklace',"<path d='M13 14h1v1h-1z' fill='#16d6bf'/><g fill='#ffd814'><path d='M11 12h1v1h-1zm3 0h1v1h-1z'/><path d='M12 13v1h1 1v-1h-1-1z'/></g>");
		art.accessory[3] = Item('Ring',"<path d='M9 16h1v1H9z' fill='#ffe922'/>");
		art.accessory[4] = Item('Gloves',"<path d='M9 15H8v1 1 1h1 1v-1h1v-1-1h-1-1zm7 0h-1v1 1 1h1v-1h1v-1-1h-1z' fill='#1c1c1c'/>");

		art.weapon[0] = Item('Bow', "<path d='M3.04 15h14v1h-14z' fill='#fff'/><path d='M5.04 17h1v1h-1zm2 0h1v1h-1zm6 0h1v1h-1zm-2 0h1v1h-1z' fill='#5b1212'/><g fill='#890f0c'><path d='M2.04 15h-1v1h1 1v-1h-1z'/><path d='M3.04 16v1h1 1v-1h-1-1zm3 1h1v1h-1zm12-2h-1v1h1 1v-1h-1z'/><path d='M15.04 16v1h1 1v-1h-1-1z'/><path d='M14.04 17h1v1h-1zm-2 0h1v1h-1zm-2 0h1v1h-1z'/></g><g fill='#913413'><path d='M2.04 16h1v1h-1z'/><path d='M3.04 17h2v1h-2zm12 0h2v1h-2z'/><path d='M17.04 16h1v1h-1zm-6 2h-1-1-1-3v1h3 1 1 1 1 3v-1h-3-1z'/></g>");
		art.weapon[1] = Item('Dagger', "<g fill='#a05000'><path d='M7 18h1v1H7zm3-3h1v1h-1z'/><path d='M9 14h1v1H9zm2 2h1v1h-1z'/></g><g fill='#71bcd3'><path d='M10 14h1v1h-1z'/><path d='M11 15h1v1h-1zm0-2h1v1h-1z'/><path d='M12 14h1v1h-1zm0-2h1v1h-1z'/><path d='M13 13h1v1h-1zm0-2h1v1h-1z'/><path d='M14 12h1v1h-1zm0-2h1v1h-1z'/><path d='M15 11h1v1h-1z'/></g><g fill='#3d94a0'><path d='M11 14h1v1h-1z'/><path d='M12 13h1v1h-1z'/><path d='M13 12h1v1h-1z'/><path d='M14 11h1v1h-1z'/><path d='M15 10h1v1h-1z'/></g>");
		art.weapon[2] = Item('Fireball', "<g fill='#ff7610'><path d='M11 14h1v1h-1zm-2-4h1v1H9z'/><path d='M11 6h1v1h-1zm-1 8H9v1 1h1v1h1v-1-1h-1v-1z'/></g><g fill='#fce03f'><path d='M11 15h1v1h-1z'/><path d='M11 13h-1v1 1h1v-1-1zm0-2h1v1h-1zM9 9h1v1H9z'/></g>");
		art.weapon[3] = Item('Halberd', "<path d='M21 5h-1v1h1 1V5h-1z' fill='#3a3a82'/><path d='M21 4h-1v1h1 1V4h-1z' fill='#6262c4'/><path d='M20 13h1v1h-1zm-2-1h1v1h-1z' fill='#333'/><g fill='#911313'><path d='M23 9h-1v1h1v1h1v-1-1h-1z'/><path d='M22 11h1v1h-1z'/><path d='M21 12h1v1h-1zm-3 1v1h1 1v-1h-1-1z'/></g><g fill='#757373'><path d='M22 3h1v1h-1zm-6 6h1v1h-1zm0-4h1v1h-1z'/><path d='M20 8V7 6h-1-1-1v1h1v1h-1v1h1v1h1v1 1h1 1v-1-1-1h-1V8z'/></g><g fill='#4c4c4c'><path d='M22 10V9 8h-1V7h-1v1 1h1v1 1 1h1v-1h1v-1h-1z'/><path d='M19 12v1h1 1v-1h-1-1zm0-7h-1V4h-1v1 1h1 1V5z'/></g><g fill='#2b1806'><path d='M5 20h1v1H5z'/><path d='M4 21h1v1H4z'/><path d='M3 22h1v1H3zm4-4h1v1H7z'/><path d='M6 19h1v1H6zm6-6h1v1h-1z'/><path d='M11 14h1v1h-1z'/><path d='M10 15h1v1h-1zm4-4h1v1h-1z'/><path d='M13 12h1v1h-1zm3-3h-1v1 1h1 1v-1h-1V9z'/><path d='M17 9h1v1h-1z'/><path d='M16 8h1v1h-1z'/></g>");
		art.weapon[4] = Item('Hatchet', "<g fill='#3a2110'><path d='M7 17h1v1H7z'/><path d='M8 18h1v1H8zm-2 0h1v1H6z'/><path d='M7 19h1v1H7zm3-5h1v1h-1z'/><path d='M6 19H5v1 1h1 1v-1H6v-1zm5-4h1v1h-1z'/></g><g fill='#6262c4'><path d='M12 13h1v1h-1z'/><path d='M13 12h1v1h-1z'/></g><g fill='#562301'><path d='M7 18h1v1H7z'/><path d='M6 19h1v1H6zm5-5h1v1h-1zm3-3h1v1h-1z'/></g><g fill='#2b1604'><path d='M11 13h1v1h-1z'/><path d='M12 14h1v1h-1zm0-2h1v1h-1z'/><path d='M13 13h1v1h-1zm0-2h1v1h-1z'/><path d='M14 12h1v1h-1z'/></g><g fill='#911313'><path d='M15 15h1v1h-1z'/><path d='M14 16h1v1h-1z'/></g><path d='M15 13h-1v1h-1v1 1h1 1v-1h1v-1-1h-1zm-2-2v-1h-1-1v1h-1v1 1h1 1v-1h1v-1z' fill='#303030'/><g fill='#141414'><path d='M16 14h1v1h-1zm-6-4h1v1h-1z'/><path d='M11 9h1v1h-1zm-2 2h1v1H9z'/></g>");
		art.weapon[5] = Item('Katana', "<path d='M7 18h1v1H7zm3-3h1v1h-1z' fill='#efa21b'/><g fill='#0a0a54'><path d='M7 17h1v1H7z'/><path d='M8 18h1v1H8z'/><path d='M7 18H6v1 1h1 1v-1H7v-1zm3-4h1v1h-1z'/><path d='M11 15h1v1h-1z'/></g><g fill='#6f868e'><path d='M11 14h1v1h-1z'/><path d='M12 13h1v1h-1z'/><path d='M13 12h1v1h-1z'/><path d='M14 11h1v1h-1zm3-3h1v1h-1z'/></g><g fill='#911313'><path d='M15 10h1v1h-1z'/><path d='M16 9h1v1h-1zm2-2h1v1h-1z'/><path d='M19 6h1v1h-1z'/><path d='M20 5h1v1h-1z'/></g><g fill='#444a4c'><path d='M11 13h1v1h-1z'/><path d='M12 12h1v1h-1z'/><path d='M13 11h1v1h-1z'/><path d='M14 10h1v1h-1z'/><path d='M15 9h1v1h-1z'/><path d='M16 8h1v1h-1z'/><path d='M17 7h1v1h-1z'/><path d='M18 6h1v1h-1z'/><path d='M19 5h1v1h-1z'/><path d='M20 4h1v1h-1z'/></g>");
		art.weapon[6] = Item('Knives', "<g fill='#71bcd3'><path d='M16 14h1v1h-1z'/><path d='M17 13h1v1h-1zm-7 1h1v1h-1z'/><path d='M11 13h1v1h-1z'/><path d='M12 12h1v1h-1z'/></g><g fill='#911313'><path d='M18 12v1 1h1v-1-1h-1z'/><path d='M17 14h1v1h-1zm-5-1h1v1h-1z'/><path d='M11 14h1v1h-1z'/></g><path d='M16 15h1v1h-1zm-6 0h1v1h-1z' fill='#3d94a0'/><g fill='#a05000'><path d='M15 15h1v1h-1z'/><path d='M16 16h1v1h-1zm-7-1h1v1H9z'/><path d='M10 16h1v1h-1z'/></g>");
		art.weapon[7] = Item('Spear', "<path d='M17 8h1v1h-1z' fill='#6262c4'/><path d='M4 21h1v1H4zm2-2h1v1H6zm6-6h1v1h-1zm-2 2h1v1h-1zm4-4h1v1h-1zm2-2h1v1h-1z' fill='#562301'/><path d='M5 20h1v1H5zm-2 2h1v1H3zm4-4h1v1H7zm4-4h1v1h-1zm2-2h1v1h-1zm2-2h1v1h-1z' fill='#3a2110'/><g fill='#2b1806'><path d='M19 8V7h-1V6h-1v1 1h1v1h1 1V8h-1z'/><path d='M16 8h1v1h-1z'/><path d='M17 9h1v1h-1z'/></g><path d='M19 7h1v1h-1zm2-2h1v1h-1z' fill='#757373'/><path d='M21 3v1h-1v1h-1v1h-1v1h1 1V6h1V5h1V4 3h-1z' fill='#4c4c4c'/><path d='M20 6h1v1h-1zm2-3v1 1h1V4 3h-1z' fill='#911313'/>");
		art.weapon[8] = Item('Sword', "<path d='M10 15h1v1h-1z' fill='#3a3a82'/><g fill='#a39f9b'><path d='M16 10h1v1h-1z'/><path d='M18 6v1 1h-1v1 1h1V9h1V8 7 6h-1z'/></g><g fill='#2b1806'><path d='M7 18h1v1H7zm2-4h1v1H9z'/><path d='M11 16h1v1h-1zm-1-3v-1H9 8v1 1h1v-1h1z'/><path d='M10 13h1v1h-1zm2 2h1v1h-1z'/><path d='M13 16v1h-1v1h1 1v-1-1h-1z'/></g><g fill='#911313'><path d='M20 5v1h-1v1 1 1h1V8 7h1V6 5h-1zm-4 6h1v1h-1z'/><path d='M18 9h1v1h-1zm-3 3h1v1h-1z'/></g><g fill='#232323'><path d='M20 5h-1-1v1h1 1V5zm-6 4h1v1h-1z'/><path d='M15 8h1v1h-1z'/><path d='M16 7h1v1h-1z'/><path d='M17 6h1v1h-1zm0 4h1v1h-1zm3-3h1v1h-1zm-7 3h1v1h-1z'/><path d='M12 11h1v1h-1zm2 2h1v1h-1z'/><path d='M11 12h1v1h-1zm2 2h1v1h-1z'/></g><g fill='#6262c4'><path d='M11 14h1v1h-1zm2-2h1v1h-1z'/><path d='M12 13h1v1h-1z'/></g><g fill='#7a7672'><path d='M16 9h-1v1 1h-1v1 1h1v-1h1v-1-1h1V9 8h-1v1z'/><path d='M17 7h1v1h-1z'/></g><g fill='#4c4c4c'><path d='M12 12h1v1h-1z'/><path d='M13 13h1v1h-1zm0-2h1v1h-1z'/><path d='M14 10h1v1h-1zm-3 3h1v1h-1z'/><path d='M12 14h1v1h-1z'/></g><g fill='#93460d'><path d='M12 16h1v1h-1z'/><path d='M11 15h1v1h-1z'/><path d='M10 14h1v1h-1z'/><path d='M9 13h1v1H9z'/></g>");
		art.weapon[9] = Item('Wand',"<g fill='#422007'><path d='M17 14h1v1h-1z'/><path d='M18 13h1v1h-1z'/><path d='M19 12h1v1h-1z'/><path d='M20 11h1v1h-1z'/><path d='M21 10h1v1h-1z'/></g><path d='M19 10h1v1h-1zm2-2h1v1h-1zm1 4h1v1h-1z' fill='#fff24d'/>");

		art.head[0] = Item('Eye Patch',"<path d='M13 7h-1v1 1h1 1V8 7h-1z' fill='#1c1c1b'/><g fill='#3f3f3f'><path d='M15 6h-1v1h1 1V6h-1zm-4 3h1v1h-1z'/><path d='M10 10h1v1h-1z'/></g>");
		art.head[1] = Item('Hat',"<path d='M8 1h1v1H8zM6 4v1h1 1V4H7 6z' fill='#29242d'/><path d='M11 3h1 1 1V2h-1V1h-1-1-1v1h1v1zm3 1h-1-1-1-1-1-1v1h1 1 1 1 1 1 1V4h-1z' fill='#372f3d'/><path d='M15 3V2 1h-1-1v1h1v1h1zm1 1h-1v1h1 1V4h-1z' fill='#4f425b'/><g fill='#2d2d2d'><path d='M5 4h1v1H5zm12 0h1v1h-1z'/><path d='M15 5h-1-1-1-1-1-1-1-1-1v1h1 1 1 1 1 1 1 1 1 1 1V5h-1-1zm0-2h-1-1-1-1-1v1h1 1 1 1 1 1 1V3h-1V2 1h-1v1 1zM8 4h1V3H8V2 1H7v1 1H6v1h1 1z'/><path d='M10 1h1 1 1 1 1V0h-1-1-1-1-1-1-1v1h1 1z'/></g><path d='M9 2h1v1H9z' fill='#f4a627'/><g fill='#2aa6f2'><path d='M8 2h1v1H8z'/><path d='M9 1h1v1H9z'/><path d='M10 2h1v1h-1z'/><path d='M9 3h1v1H9z'/></g>");
		art.head[2] = Item('Headband',"<path d='M15 6h1v1h-1zM8 6v1h1 1V6H9 8z' fill='#af2825'/><path d='M14 6h-1-1-1-1v1h1 1 1 1 1V6h-1zM7 5h1v1H7zm0 2h1v1H7z' fill='#db3931'/>");
		art.head[3] = Item('Horned',"<g fill='#757373'><path d='M10 8v1 1 1 1h1v-1-1-1-1-1h-1v1zm2-4h1v1h-1zm3 0h1v1h-1z'/><path d='M14 3h1v1h-1zm-3 3h1v1h-1z'/></g><g fill='#333'><path d='M14 2h-1-1-1-1-1v1h1 1 1 1 1 1V2h-1z'/><path d='M15 3h1v1h-1z'/><path d='M16 4v1h-1-1-1-1v1 1h1V6h1 1 1v1 1 1h1V8 7 6 5 4h-1zm0 7v1h1v-1-1h-1v1zM7 9V8 7 6 5 4H6v1 1 1 1 1 1 1h1v-1-1z'/><path d='M9 11H8 7v1h1 1 1v-1H9z'/><path d='M10 12h1v1h-1z'/><path d='M11 8v1 1 1 1h1v-1-1-1-1-1h-1v1z'/></g><path d='M9 6H8V5H7v1 1 1 1 1 1h1 1 1v-1-1-1-1H9V6zm5-2V3h-1-1-1-1v1h1 1 1v1h1 1V4h-1z' fill='#4c4c4c'/><g fill='#ffd814'><path d='M9 6v1h1 1V6h-1-1z'/><path d='M8 5h1v1H8zm3 0h1v1h-1z'/></g><g fill='#ffed6c'><path d='M10 4V3H9V2h1V1H9 8v1H7v1 1 1h1 1v1h1 1V5h1V4h-1-1z'/><path d='M10 0h1v1h-1zm4 0h1v1h-1z'/><path d='M15 1v1 1h1V2 1h-1z'/></g>");
		art.head[4] = Item('Knight',"<g fill='#333'><path d='M15 10h1v1h-1z'/><path d='M10 12h1 1 1 1 1v-1h-1-1-1-1-1-1v1h1zM8 3H7v1H6v1 1 1 1 1 1h1V9 8 7 6 5h1V4 3z'/><path d='M8 5h1v1H8z'/><path d='M14 6h-1-1-1-1-1v1 1h1V7h1 1 1 1 1 1V6h-1-1z'/><path d='M16 3h-1V2h-1-1-1-1-1-1-1v1h1 1v1 1h1V4 3h1v1 1h1V4 3h1v1 1h1V4h1v1 1h1V5 4 3h-1zm-8 8h1v-1H8 7v1h1zm0-3h1v1H8z'/></g><g fill='#4c4c4c'><path d='M7 6v1 1 1 1h1 1v1h1 1 1v-1h-1-1V9H9V8H8V7 6 5H7v1z'/><path d='M14 5V4h-1v1h-1V4h-1v1h-1V4H9V3H8v1 1h1v1h1 1 1 1 1 1V5h-1z'/></g><g fill='#757373'><path d='M9 6H8v1 1h1V7 6z'/><path d='M10 8H9v1h1v1h1V9 8 7h-1v1zm3 2h-1v1h1 1 1v-1h-1-1zm-2-7h1v1h-1zM9 3h1v1H9zm4 0h1v1h-1zm2 1v1 1h1V5 4h-1z'/></g><path d='M7 1h-.07V0H6 5v1H4 3v1h1 1V1h1v1h1v1h1V2 1H7zM2 4v1h1V4 3H2v1zm2 3h1v1H4z' fill='#a0103a'/><path d='M6 2V1H5v1H4 3v1 1 1 1 1h1V6 5 4h1V3h1 1V2H6zM3 9v1h1V9 8H3v1z' fill='#ce3a45'/>");
		art.head[5] = Item('White Eyes',"<path d='M12 8h1v1h-1zm3 0h1v1h-1z' fill='#fff'/>");

		art.shoes[0] = Item('Big Shoes', "<path d='M10 21h1v1h-1zm4-1h1v1h-1zm-2 0h1v1h-1z' fill='#ccc'/><path d='M13 20h1v1h-1zm-4 1h1v1H9zm2-1h1v1h-1z' fill='#a0a0a0'/><path d='M15 22v-1h-1-1-1-1v1h-1-1v1 1h1 1 1 1 1 1 1v-1-1h-1z' fill='#1c1c1c'/>");
		art.shoes[1] = Item('Sandals', "<path d='M15 23h-1-1-1-1-1-1v1h1 1 1 1 1 1 1v-1h-1z' fill='#331602'/><path d='M12 22h1v1h-1zm2 0h1v1h-1z' fill='#542a0d'/>");
		art.shoes[2] = Item('Shoes', "<path d='M15 22v1h-1-1-1-1-1-1v1h1 1 1 1 1 1 1v-1-1h-1z' fill='#1c1c1c'/><path d='M13 22h1v1h-1zm-2 0h1v1h-1z' fill='#a0a0a0'/><path d='M14 22h1v1h-1zm-4 0h1v1h-1zm2 0h1v1h-1z' fill='#ccc'/>");
		art.shoes[3] = Item('Winged Shoes', "<path d='M15 22v-1-1h-1-1-1v1 1 1h-1v-1h-1-1v1 1h1 1 1 1 1 1 1v-1-1h-1z' fill='#1c1c1c'/><g fill='#fce792'><path d='M9 19H8 7v1h1 1 1v-1H9z'/><path d='M10 20v1H9 8v1h1 1 1v-1-1h-1z'/></g><g fill='#ffd814'><path d='M11 20v1 1 1h1v-1-1-1h-1z'/><path d='M10 19h1v1h-1z'/><path d='M9 18H8 7v1h1 1 1v-1H9zm-1 2v1h1 1v-1H9 8z'/></g>");

		art.torso[0] = Item('Armor',"<g fill='#333'><path d='M6 12H5v1h1v1 1h1v-1-1h1v-1H7v-1H6v1z'/><path d='M8 10H7v1h1 1v-1H8z'/><path d='M9 11h1v1H9z'/><path d='M11 12h-1v1 1h1v-1-1zm4-1h1v1h-1z'/><path d='M16 12h1v1h-1zm-5 3v1 1h1v-1-1-1h-1v1z'/><path d='M13 12v1h1v1 1 1 1 1h1v-1-1-1-1-1-1h-1-1zm-3 5h1v1h-1z'/></g><path d='M7 11v1h1 1v-1H8 7zm6 4h1v1h-1zm0-2h1v1h-1zm0 4h1v1h-1z' fill='#5b0000'/><g fill='#757373'><path d='M8 12h1v1H8zm5 4h-1v1h1 1v-1h-1z'/><path d='M11 17h1v1h-1z'/></g><g fill='#4c4c4c'><path d='M15 12v1 1 1h1v-1-1-1h-1zm-9 3h1v1H6z'/><path d='M13 13v-1h-1-1v1h-1v-1H9v1H8 7v1 1h1v-1h1 1v1h1v-1h1v1 1h1v-1h1v-1h-1v-1zm-1 4h1v1h-1z'/></g>");
		art.torso[1] = Item('Backpack',"<g fill='#700d0d'><path d='M10 13h1v1h-1zm4 0h1v1h-1zm-8 3h1v1H6z'/><path d='M7 17h1v1H7z'/><path d='M8 18v1h1 1v-1H9 8z'/></g><path d='M10 12h1v1h-1zm4 0h1v1h-1zm-7-2H6 5v1H4v1 1 1 1 1 1h1v1h1v1h1 1v-1H7v-1H6v-1-1-1-1-1h1v-1h1v-1-1H7v1z' fill='#c62828'/>");
		art.torso[2] = Item('Beard',"<g fill='#c1c1c1'><path d='M10 10h1v1h-1z'/><path d='M11 11h1v1h-1z'/><path d='M13 12h-1v1 1h1v-1-1zm2 0v1 1 1h1v-1-1-1h-1z'/><path d='M9 9h1v1H9zm5 6h1v1h-1z'/><path d='M13 14h1v1h-1z'/></g><g fill='#9e9e9e'><path d='M9 10h1v1H9z'/><path d='M10 11h1v1h-1z'/><path d='M12 12h-1v1 1h1v-1-1zm1 3h1v1h-1z'/><path d='M12 14h1v1h-1zM9 8H8v1 1h1V9 8z'/></g><g fill='#e0e0e0'><path d='M15 10h-1-1-1-1v1h1v1h1v1 1h1v1h1v-1-1-1h1v-1-1h-1z'/><path d='M10 9h1v1h-1z'/><path d='M9 8h1v1H9z'/></g>");
		art.torso[3] = Item('Cape',"<g fill='#926d1d'><path d='M7 18v-1-1H6v1 1 1h1v-1z'/><path d='M6 21v-1-1H5v1 1 1h1v-1z'/><path d='M10 20v1 1 1H9 8 7 6 5v-1H4v1 1h1 1 1 1 1 1 1v-1-1-1-1h-1z'/></g><g fill='#292975'><path d='M7 17h1v1H7zm-1 3h1v1H6z'/><path d='M8 18h1v1H8z'/><path d='M7 19h1v1H7zm0 2h1v1H7z'/><path d='M6 22h1v1H6zm2-2h1v1H8zm2-2h1v1h-1z'/><path d='M9 19h1v1H9zm0 2h1v1H9z'/><path d='M8 22h1v1H8zm3-5h1v1h-1z'/></g><g fill='#c0942b'><path d='M7 18h1v1H7z'/><path d='M6 19h1v1H6zm0 2h1v1H6z'/><path d='M5 22h1v1H5zm2-2h1v1H7zm2-2h1v1H9z'/><path d='M8 19h1v1H8zm0 2h1v1H8z'/><path d='M7 22h1v1H7zm2-2h1v1H9z'/><path d='M10 19h1v1h-1zm-1 3h1v1H9zm1-5h1v1h-1z'/><path d='M11 16h1v1h-1z'/></g>");
		art.torso[4] = Item('Satchel',"<path d='M11 14h1v1h-1z' fill='#5b1b0e'/><g fill='#ea1c44'><path d='M14 12h1v1h-1zm-1 3h-1v1h-1v1h1 1v-1h1v-1-1h-1v1z'/><path d='M10 17h1v1h-1z'/></g><g fill='#b21f45'><path d='M12 14h1v1h-1z'/><path d='M11 15h1v1h-1zm2-2h1v1h-1z'/></g>");
		art.torso[5] = Item('Scabbard',"<path d='M13 17h1v1h-1z' fill='#ff0025'/><path d='M11 17v1h1 1v-1h-1-1zm3 0h1v1h-1z' fill='#474747'/><g fill='#ffb757'><path d='M7 20h1v1H7z'/><path d='M6 21h1v1H6z'/><path d='M6 22H5v1 1h1 1v-1H6v-1z'/><path d='M7 22h1v1H7z'/><path d='M8 21h1v1H8z'/><path d='M9 20h1v1H9z'/><path d='M10 19h1v1h-1z'/><path d='M11 18h1v1h-1zm-3 1h1v1H8z'/><path d='M9 18h1v1H9z'/><path d='M10 17h1v1h-1z'/></g><g fill='#e5ac1c'><path d='M6 22h1v1H6z'/><path d='M7 21h1v1H7z'/><path d='M8 20h1v1H8z'/><path d='M9 19h1v1H9z'/><path d='M10 18h1v1h-1z'/></g>");
		art.torso[6] = Item('Scarf',"<path d='M11 13h1v1h-1zm1-3h-1-1-1v1h1v1h1v-1h1 1v-1h-1z' fill='#af2825'/><path d='M11 14h1v1h-1zm4-4h-1-1v1h-1-1v1h-1v1h1 1 1 1v-1h1v-1h1v-1h-1z' fill='#db3931'/>");

		art.altPart = [
			"<path d='M14 16h-1-1-1v1 1h1v1h1 1v-1h1v-1-1h-1z'/>",
			altPartForBardClericAndDruid,
			altPartForBardClericAndDruid,
			altPartForBardClericAndDruid,
			"<path d='M14 18h-1-1-1-1v1H9v1 1 1h1 1v-1h1 1 1 1v-1-1-1h-1z'/>",
			"<path d='M14 19h-1-1-1-1-1v1 1 1 1h1 1v-1h1 1 1 1v-1-1-1h-1z'/>",
			"<path d='M14 19h-1-1-1-1-1v1 1 1h1 1v-1h1 1 1 1v-1-1h-1z'/>",
			"<path d='M10.99 16v1h-1v2h-1v1 1 1 1h1 1v-1h1 1 1 1v-1-1-1-3h-4z'/>",
			"<path d='M14 19h-1-1-1-1-1v1 1 1 1h1 1v-1h1 1 1 1v-1-1-1h-1zm-2-9V9h-2v3h1 1 4v-2h-4z'/>",
			"<path d='M11 12v8h-1-1v1 1 1h1 1v-1h1 1 1 1v-1-1-8h-4z'/>",
			"<path d='M16 10h-6V9H8v2h2v2h1v7h-1-1v1 1 1h1 1v-1h1 1 1 1v-1-1-7h1v-3z'/>"];
		art.colorPart = [
			"<path d='M11 12h-1v-1H9v-1H8 7v1 1H6v1 1 1 1h1v-1h1v-1h1 1v1h1v1h1v-1-1-1h1v-1h-1-1zm4-1v1h-1v1 1 1 1h1v-1-1h1v-1-1-1h-1z'/>",
			"<path d='M15 11v1h-1-1-1-1-1v-1H9v-1H8 7v1H6v1 1h1 1 1 1v1 1h1v1 1h-1v2H9v2h2v-1h1 3v-3-1-1-1-1h1v-1-1h-1z'/>",
			"<path d='M15 11v1h-1-1-1-1-1v-1H9v-1H8v1H7v1H6v1 1 1 1h1v-1h1 2 1v1 1h-1v1 1H9v1 1 1h1 1v-1h1 1 1v-1h1v-1-1-1-1-1h1v-1-1-1-1h-1z'/>",
			"<path d='M15 11v1h-1-1-1-1-1v-1H9v-1H8 7v1 1H6v1 1 1 1h1v-1h1 2 1v1 1h-1v1 1H9v1 1h2v-1h4v-1-1-1-1-1h1v-1-1-1-1h-1z'/>",
			"<path d='M15 11v1h-1-1-1-1-1v-1H9v-1H8 7v1H6v1H5v1h1v1 1 1h1v-1h1 2 1v1 1 1h1 1 1 1v-1-1-1h1v-1-1-1-1h-1z'/>",
			"<path d='M15 11v1h-1-1-1-1-1v-1H9v-1H8v1H7v1H6v1 1 1 1h1v-1h1 2 1v1 1h-1v1 1h1 1 1 1 1v-1-1-1-1h1v-1-1-1-1h-1z'/>",
			"<path d='M16 12v-1h-1v1h-1-1-1-1-1v-1H9v-1H8 7v1H6v1 1 1 1 1h1v-1h1 2 1v1 1h-1v1 1h1 1 1 1 1v-1-1-1-1h1v-1-1h1v-1h-1z'/>",
			"<path d='M14.99 11v1h-1-1-1-1-1v-1h-1v-1h-1-1v1h-1v1 1h1 1 1 1v1 1h1v1h1 1 1 1v-1-1-1h1v-1-1h-1z'/>",
			"<path d='M16 4V3h-1V2H8v1H7v1H6v5h1v2 1H6v1 1 1 1h1v-1h1 2 1v1 1h-1v1 1H9v1h3v-1h1 1 1v-1-1-1-1h1v-1-1-1-1h-1v1h-1-1-1v-1h-1v-1h-1V9h1V8h1V6h3v1h1v2h1V4h-1z'/>",
			"<path d='M11 12h-1v-1H9v-1H8v1H7v1H6v6h1v1h1v2H7v3h2v-2h1v-1h1v-2h1v-6h-1zm0 4v1h-1v1H9v-2h1v-1h1zm4-5v1h-1v1h-1v1 1 1 1 1 1 1h1v1 1h1v-1-1-1-1-1-1-1h1v-1-1-1-1h-1z'/>",
			"<path d='M11 12h-1v-1H9v-1H8v1H7v1H6v6h1v1h1v2H7v3h2v-2h1v-1h1v-2h1v-6h-1zm0 4v1h-1v1H9v-2h1v-1h1zm4-5v1h-1v1h-1v1 1 1 1 1 1 1h1v1 1h1v-1-1-1-1-1-1-1h1v-1-1-1-1h-1z'/>"];
		art.shadowPart = [
			"<path d='M6 13v1 1 1h1v-1-1-1-1H6v1zm1-3v1h1 1v-1H8 7zm4 4v1 1h1v-1-1-1h-1v1zm4-3h1v1h-1z'/><path d='M12 12h1v1h-1zm2 1v1 1 1h1v-1-1-1-1h-1v1z'/>",
			"<path d='M10 19H9v1 1h1 1v-1h-1v-1z'/><path d='M11 18v-1h-1v1 1h1v-1z'/><path d='M11 16h1v1h-1z'/><path d='M14 13v1 1 1 1h-1-1v1h1 1v1h-1-1-1v1h1 1 1 1v-1-1-1-1-1-1-1-1h-1v1zm-5-3H8 7v1h1 1v-1z'/><path d='M11 14v-1h1v-1h-1-1v1 1 1h1v-1zm-5-2v1h1v-1-1H6v1zm9-1h1v1h-1z'/>",
			"<path d='M12 20h-1v1h1 1 1v-1h-1-1z'/><path d='M10 20v-1H9v1 1 1h1 1v-1h-1v-1z'/><path d='M11 18v-1h-1v1 1h1v-1zm-5-5v1 1 1h1v-1-1-1-1H6v1z'/><path d='M14 13h-1-1v-1h-1v1 1 1 1 1h1v-1-1-1h1v1h1v1 1 1 1 1h1v-1-1-1-1-1-1-1-1h-1v1zm-6-3h1v1H8z'/><path d='M15 11h1v1h-1zm-8 0h1v1H7z'/>",
			"<path d='M10 19H9v1 1h1 1v-1h-1v-1z'/><path d='M14 19h-1-1-1v1h1 1 1 1v-1-1h-1v1zm-4-2h1v1h-1zm-4-4v1 1 1h1v-1-1-1-1H6v1zm8 0v1 1h-1v1h1 1v-1-1-1-1h-1v1z'/><path d='M9 10H8 7v1h1 1v-1zm4 3h-1v-1h-1v1 1 1 1 1h1v-1-1h1v-1-1z'/><path d='M15 11h1v1h-1zm-6 0h1v1H9z'/>",
			"<path d='M14 13h-1-1v1 1h1v-1h1v1 1 1 1h1v-1-1-1-1-1-1h-1v1zm-7-3v1h1 1v-1H8 7zm4 3v-1h-1v1 1 1h1v-1-1z'/><path d='M11 16v1 1h1v-1-1-1h-1v1zm4-5h1v1h-1zm-9 1H5v1h1v1 1 1h1v-1-1-1h1 1v-1H8 7v-1H6v1z'/>",
			"<path d='M12 16v-1h1v-1h-1v-1-1h-1v1 1 1 1 1h1v-1zm-6-3v1 1 1h1v-1-1-1-1H6v1z'/><path d='M14 13h-1v1h1v1 1 1 1h-1-1-1v-1h-1v1 1h1 1 1 1 1v-1-1-1-1-1-1-1h-1v1zm-6-3h1v1H8z'/><path d='M15 11h1v1h-1zm-8 0h1v1H7z'/>",
			"<path d='M12 18h1v1h-1zm-2 0v1h1v-1-1h-1v1z'/><path d='M14 13h-1-1v1h1 1v1h-1-1v1h1 1v1h-1v1h1v1h1v-1-1-1-1-1-1-1h-1v1zm-7-3v1h1 1v-1H8 7z'/><path d='M10 13v1 1h1v-1-1-1h-1v1zm5-2h1v1h-1z'/><path d='M6 12v1 1 1 1h1v-1-1-1h1 1v-1H8 7v-1H6v1zm10 0h1v1h-1z'/>",
			"<path d='M13.99 13h-1v1h1v1h-1v1h1 1v-1-1-1-1h-1v1zm-7-3v1h1 1v-1h-1-1z'/><path d='M11.99 14h1v1h-1zm0-2h1v1h-1zm-6 0v1h1v-1-1h-1v1zm9-1h1v1h-1z'/><path d='M11.99 14v-1h-1v-1h-1v1 1 1h1v-1h1z'/><path d='M10.99 15h1v1h-1z'/>",
			"<path d='M11 18v-1h-1v1 1H9v1h1 1 1v-1h-1v-1z'/><path d='M12 16v-1-1-1-1h-1v1 1 1 1 1h1v-1zm-6-3v1 1 1h1v-1-1-1-1H6v1zm8 0v1 1 1 1 1h-1-1v1h1 1 1v-1-1-1-1-1-1-1h-1v1z'/><path d='M15 11h1v1h-1zM8 9H7v1 1h1 1v-1H8V9z'/><path d='M7 7V6 5 4H6v1 1 1 1 1h1V8 7z'/><path d='M7 3h1v1H7z'/><path d='M10 3h1 1 1 1 1V2h-1-1-1-1-1-1-1v1h1 1z'/><path d='M15 3h1v1h-1z'/><path d='M16 4v1 1h-1v1h1v1 1h1V8 7 6 5 4h-1zM9 9h1v1H9z'/><path d='M14 5h-1-1-1v1 1 1h1V7 6h1 1 1V5h-1z'/><path d='M10 8h1v1h-1z'/>",
			shadowPartForSorcererAndWizard,
			shadowPartForSorcererAndWizard];
		art.basePart = [
			"<g fill='#473f3e'><path d='M9 7v1h1V7 6H9v1z'/><path d='M10 5h1v1h-1z'/><path d='M11 4h1v1h-1zM9 7v1h1V7 6H9v1z'/><path d='M10 5h1v1h-1z'/><path d='M11 4h1v1h-1z'/></g><path d='M11 7v1h1 1V7h-1-1zm4 0h-1v1h1 1V7h-1z' fill='#4c1d0c'/><path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#e20000'/><g fill='#473f3e'><path d='M7 15h1v1H7z'/><path d='M7 16h1v1H7zm1-2h1v1H8z'/><path d='M9 14h1v1H9zm7 1h-1v-1h1z'/></g>",
			"<path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#ff8de4'/><g fill='#5e2f0d'><path d='M11 7v1h1V7 6h-1v1z'/><path d='M16 4V3h-1V2h-1-1-1-1-1-1v1H8v1H7v1 1 1 1 1 1h1V9 8 7h1v1 1h1V8 7 6h1V5h1v1h1V5h1v1h1v1h1V6h1V5 4h-1zm-5 5h1v1h-1z'/></g><path d='M12 9h-1V8h1z' fill='#473f3e'/>",
			"<path d='M15 3V2h-1-1-1-1-1-1v1H8v1H7v1 1 1 1 1 1h1V9 8 7h1v1h1V7 6H9V5 4h1V3h1 1 1 1v1h1v1 1h1V5 4 3h-1z' fill='#a0a0a0'/><path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#8996c9'/><g fill='#473f3e'><path d='M7 16v1h1v-1-1H7v1z'/><path d='M8 14v1h1 1v-1H9 8zm7 0h1v1h-1z'/></g>",
			"<path d='M7 8H6v1h1 1V8H7z' fill='#473f3e'/><path d='M6 9v1H5v1 1 1h1v-1h1v-1-1h1V9H7 6zm10-5V3h-1V2h-1-1-1-1-1-1v1H8v1H7v1H6v1 1 1h1 1V7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1z' fill='#5e2f0d'/><path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#58b71a'/><g fill='#473f3e'><path d='M7 16v1h1v-1-1H7v1z'/><path d='M8 14v1h1 1v-1H9 8zm7 0h1v1h-1z'/></g><path d='M14 16h-1v1 1h1 1v-1-1h-1z' fill='#56290a'/><path d='M15 10h-1-1-1v1 1h1 1 1v-1h1v-1h-1z' fill='#63d6ba'/><g fill='#b2b2b2'><path d='M11 10h1v1h-1z'/><path d='M10 9h1v1h-1z'/><path d='M9 8h1v1H9z'/></g>",
			"<path d='M11 7v1h1 1V7h-1-1zm4 0h-1v1h1 1V7h-1z' fill='#5e2f0d'/><path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#ccc356'/><path d='M16 4V3h-1V2h-1-1-1-1-1-1v1H8v1H7v1 1 1 1 1h1V8 7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1z' fill='#5e2f0d'/><g fill='#473f3e'><path d='M7 16v1h1v-1-1H7v1z'/><path d='M8 14v1h1 1v-1H9 8zm7 0h1v1h-1z'/></g>",
			"<path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#2b3fb2'/><path d='M16 4V3h-1-1v1h-1-1-1V3h-1-1-1v1H7v1H6v1 1 1h1v1h1V8 7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1z' fill='#5e2f0d'/><g fill='#473f3e'><path d='M7 16v1h1v-1-1H7v1z'/><path d='M8 14v1h1 1v-1H9 8zm7 0h1v1h-1z'/></g>",
			"<path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#2b3fb2'/><path d='M11 7v1h1 1V7h-1-1zm4 0h-1v1h1 1V7h-1zm1-3V3h-1V2h-1-1-1 0-1 0-1-1v1H8v1H7v1H6v1 1 1h1 1V7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1zM6 9v1H5v1 1 1h1v-1-1h1v-1h1V9H7 6z' fill='#e5cf30'/><path d='M7 8H6v1h1 1V8H7z' fill='#473f3e'/><g fill='#473f3e'><path d='M7 16v1h1v-1-1H7v1z'/><path d='M8 14v1h1 1v-1H9 8zm7 0h1v1h-1z'/></g>",
			"<path d='M14.99 8h1v1h-1zm-3 0h1v1h-1z' fill='#5adbf9'/><path d='M15.99 4V3h-1V2h-1-1-1-1-1-1v1h-1v1h-1v1 1 1 1h1V7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1z'/>",
			"<path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#7f0a74'/><g fill='#473f3e'><path d='M7 16v1h1v-1-1H7v1z'/><path d='M8 14v1h1 1v-1H9 8zm7 0h1v1h-1z'/></g>",
			"<path d='M16 4V3h-1V2h-1-1-1-1-1-1v1H8v1 1H7v1 1 1 1 1h1V9 8 7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1z' fill='#a0a0a0'/><path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#ed7f43'/>",
			"<path d='M15 8h1v1h-1zm-3 0h1v1h-1z' fill='#e53c8d'/><g fill='#87491b'><path d='M16 4V3h-1V2h-1-1-1-1-1-1v1H8v1 1H7v1 1 1 1 1h1V9 8 7h1v1h1V7 6h1V5h1 1 1 1v1h1 1V4h-1z'/><path d='M15 7h-1v1h1 1V7h-1zm-4 0v1h1 1V7h-1-1z'/></g>"];

		maxSupply = _maxSupply;
		skins = SummonerSkins(msg.sender);
    }
    
	function tokenURI(uint256 _tokenId, uint256 _dna) external view returns (string memory) {
		return string(abi.encodePacked("data:application/json;base64,",Base64.encode(bytes(metadata(_tokenId,_dna)))));
	}
	
	// private funcs
	
	function metadata(uint256 _tokenId, uint256 _dna) private view returns (string memory) {
		uint8[8] memory dna = splitNumber(_dna);

		Item[5] memory artItems = [
			art.accessory[dna[0]],
			art.weapon[dna[1]],
			art.head[dna[2]],
			art.shoes[dna[3]],
			art.torso[dna[4]]
		];

		string memory attributes;

		string[5] memory traitType = ['Accessory','Weapon','Head','Shoes','Torso'];

		for (uint256 i = 0; i < artItems.length; i++) {
			if (artItems[i].name == '') continue;

			attributes = string(abi.encodePacked(attributes,
				bytes(attributes).length == 0	? "{" : ", {",
					"'trait_type': '", traitType[i],"',",
					"'value': '", bytes12ToString(artItems[i].name), "'",
				"}"
			));
		}

		return string(abi.encodePacked(
			"{",
				"'name': 'Rare Skin #", _tokenId.toString(), "',", 
				"'description': 'Rare Skins are randomly generated and have 100% on-chain art and metadata - Only ",maxSupply.toString()," will ever exist!',",
				"'image': 'data:image/svg+xml;base64,", Base64.encode(imageData(_tokenId, _dna)), "',",
				"'attributes': [", attributes, "]",
			"}"
		));
	}
	
	function imageData(uint256 _tokenId, uint256 _dna) private view returns (bytes memory) {
		uint8[8] memory dna = splitNumber(_dna);
		uint class = skins.class(_tokenId) - 1;

		string memory skinOfRanger = class == 7 || class == 1 ? string(abi.encodePacked("<path d='M15.99 11v-1h1V9h-1V5h-1V4h-1V3h-4v1h-1v1h-1v5h1v1h1v2h-1-1-1v1 1 1h1v2h2v1h-1v5h1 5 1v-1h-1v-5h1v-1h1v-2h-1v-1-1h-1v-2h1z' fill='#",art.skinColor[dna[7]],"'/>")) : "";

		return abi.encodePacked(
			'<svg id="rare skin', _tokenId.toString(), '" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">',
				"<path fill='#",art.skinColor[dna[7]],"' d='M16 11v-1h1V9h-1V5h-1V4h-1V3h-4v1H9v1H8v5h1v1h1v4H8v3h2v1H9v5h1 5 1v-1h-1v-5h1v-1h1v-2h-2v-4h1z'/>", // skin
				skinOfRanger,
				"<path d='M12 7h1v1h-1zm3 0h1v1h-1z' fill='#fff'/>", // base eyes
				"<g fill='#",art.altColor[dna[5]],"'>",
					art.altPart[class],
				"</g>",
				"<g fill='#",art.baseColor[dna[6]],"'>",
					art.colorPart[class],
				'</g>',
				'<g opacity=".23">',
					art.shadowPart[class],
				'</g>',
				art.basePart[class],
				accessoriesSvg(dna),
			'</svg>'
		);
	}

	function accessoriesSvg(uint8[8] memory dna) private view returns (string memory) {
		return(string(abi.encodePacked(
				art.torso[dna[1]].svg,
				art.head[dna[0]].svg,
				art.accessory[dna[2]].svg,
				art.shoes[dna[3]].svg,
				art.weapon[dna[4]].svg)));
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

	function bytes12ToString(bytes12 _bytes12) internal pure returns (string memory) {
		uint8 i = 0;
		while(i < 12 && _bytes12[i] != 0) {
			i++;
		}

		bytes memory bytesArray = new bytes(i);
		for (i = 0; i < 12 && _bytes12[i] != 0; i++) {
			bytesArray[i] = _bytes12[i];
		}

		return string(bytesArray);
	}
}