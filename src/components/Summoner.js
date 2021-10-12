import { useContractCall } from "@usedapp/core"
import { ethers } from "ethers"
import * as addresses from "../addresses.json"
import * as summonerSkinsJson from "../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json"
import * as managerJson from "../artifacts/contracts/RaritySkinManager.sol/RaritySkinManager.json"
import * as rarityABI from "../dependencies/RarityABI.json"
import Loading from "./Loading"
import emptyImg from "../dependencies/empty.png"
import { Card } from "react-bootstrap"
import LoadingGif from "../dependencies/loading.gif"

export default function Summoner({id, managerAddress}){
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const skinStruct = useContractCall({abi : managerInterface, address: managerAddress[0], method: "skinOf", args: [id]})
    
    return(
        <>
            {!skinStruct && <Loading/>}
            {skinStruct && <_Summoner id={id} skinId={skinStruct[1].toNumber()} />}
        </>
    )
}

function _Summoner({id, skinId}){
    const rarityAddress = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
    const classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"]
    const rarityInterface = new ethers.utils.Interface(JSON.stringify(rarityABI.default))
    const summonerClass = useContractCall({abi: rarityInterface, address: rarityAddress, method: 'class', args: [id.toString()]})

    return(
        <>
            {!summonerClass && <div>Loading...&nbsp;</div>}
            {summonerClass && <>
                <Card style={{ width: '15rem', margin: "0.2rem", paddingTop: "1rem"}} bg="dark">
                    {skinId === 0 && <Card.Img src={emptyImg}/>}
                    {skinId !== 0 && <CardSkinImage skinId={skinId}/>}
                    <Card.Body>
                        <Card.Title>{classes[summonerClass - 1]}</Card.Title>
                        <Card.Text>
                            {id}
                            {skinId === 0 && <><br/>no skin</>}
                            {skinId !== 0 && <><br/>Rare Skin #{skinId}</>}
                        </Card.Text>
                    </Card.Body>
                </Card>
            </>}
        </>
    )
}

function CardSkinImage({skinId}){
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const skinBase64 = useContractCall({abi : skinsInterface, address: addresses.summonerSkins, method: "tokenURI", args: [skinId]})

    let imgUri
    if(skinBase64 !== undefined){
        let skinJson
        skinJson = decodeURI(skinBase64)
        skinJson = skinJson.split("data:application/json;base64,").pop()
        skinJson = JSON.parse(atob(skinJson))
        imgUri = skinJson.image
    }

    return(
        <>
            {!skinBase64 && <Card.Img src={LoadingGif} />}
            {skinBase64 && <Card.Img src={imgUri}/>}
        </>
    )
}