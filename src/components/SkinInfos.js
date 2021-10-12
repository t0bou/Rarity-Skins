import { useContractCall, useContractFunction } from "@usedapp/core"
import { ethers } from "ethers"
import * as addresses from "../addresses.json"
import * as summonerSkinsJson from "../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json"
import * as managerJson from "../artifacts/contracts/RaritySkinManager.sol/RaritySkinManager.json"
import Loading from "./Loading"
import { Card, Button, Stack, Form } from "react-bootstrap"
import { useState } from "react"
import LoadingGif from "../dependencies/loading.gif"
import * as statsJson from "../rare_skins_stats.json"

export default function SkinInfos({id, managerAddress}){
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const owner = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method: "ownerOf", args: [id.toString()]})
    const skinBase64 = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method: "tokenURI", args: [id.toString()]})
    const skinClass = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method:"class", args:[id.toString()]})
    const skinKey = useContractCall({abi: managerInterface, address: managerAddress[0], method: "skinKey", args: [[addresses.summonerSkins, id.toString()]]})
    const classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"]

    let skinJson
    let imgUri
    let attributesInfos = []
    let rarityScore = 0

    if(skinBase64){
        skinJson = decodeURI(skinBase64)
        skinJson = skinJson.split("data:application/json;base64,").pop()
        skinJson = JSON.parse(atob(skinJson))
        imgUri = skinJson.image
    }

    if (skinJson){
        let tempScore

        skinJson.attributes.forEach(attribute => {
            tempScore = statsJson.default[attribute.trait_type][attribute.value]
            tempScore = tempScore.slice(0,-1)
            tempScore = 100 - parseFloat(tempScore)
            rarityScore += tempScore
            attributesInfos.push(<li key={attribute.trait_type}>{attribute.value} -&nbsp;
                <div style={{display: "inline-block", color:"#05d5ff", fontWeight: "bolder"}}>
                    {statsJson.default[attribute.trait_type][attribute.value]}
                </div>
                &nbsp;have this</li>)
        })
    }

    return(
        <Card style={{ width: '30em', paddingTop: "1rem", alignSelf: "center"}} bg="dark">
            {!skinBase64 && <Card.Img src={LoadingGif}/>}
            {skinBase64 && <Card.Img src={imgUri}/>}
            <Card.Body>
                {skinClass && skinKey && owner && <>
                    <Card.Title>{skinJson.name}</Card.Title>
                    <Card.Text>
                    {classes[skinClass - 1]}<br/>
                    owned by {owner}<br/>
                    {<Assignation skinKey={skinKey} managerAddress={managerAddress} />}<br/>
                    {skinJson && <>
                        <div style={{display: "inline-block", color:"#ff05f7", fontWeight: "bolder"}}>
                            {Object.keys(skinJson.attributes).length}
                        </div>
                        &nbsp;Attributes -&nbsp;
                        <div style={{display: "inline-block", color:"#ff05f7", fontWeight: "bolder"}}>
                            {statsJson.default[Object.keys(skinJson.attributes).length]}
                        </div> have this number of attributes
                        <ul>
                        {attributesInfos}
                        </ul>
                        Rarity Score : <div style={{display: "inline-block", color:"#fff200", fontWeight: "bolder"}}>
                            {Math.round(rarityScore * 10)/10}
                        </div>
                    </>}
                </Card.Text></>}
                {(!skinClass || !owner || !skinKey) && <Loading/>}
            </Card.Body>
        </Card>
    )
}

function Assignation({skinKey, managerAddress}){
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const assignation = useContractCall({abi: managerInterface, address: managerAddress[0], method: "summonerOf", args: [skinKey[0]]})

    if (!assignation) return <Loading/>
    if (assignation == 0) return <>unassigned</>
    else return <>skin of {assignation.toString()}</>
}