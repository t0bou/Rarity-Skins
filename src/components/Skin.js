import { useContractCall, useContractFunction } from "@usedapp/core"
import { ethers } from "ethers"
import * as addresses from "../addresses.json"
import * as summonerSkinsJson from "../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json"
import * as managerJson from "../artifacts/contracts/RaritySkinManager.sol/RaritySkinManager.json"
import Loading from "./Loading"
import { Card, Button, Stack, Form } from "react-bootstrap"
import { useState } from "react"

export default function Skin({account, index, managerAddress}){
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const skinId = useContractCall({abi : skinsInterface, address: addresses.summonerSkins, method: "tokenOfOwnerByIndex", args: [account,index.toString()]})

    return(
        <>
            {!skinId && <Loading/>}
            {skinId && <_Skin id={skinId} managerAddress={managerAddress}/>}
        </>
    )
}

function _Skin({id,managerAddress}){
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const skinBase64 = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method: "tokenURI", args: [id.toString()]})
    const skinClass = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method:"class", args:[id.toString()]})
    const managerContract = new ethers.Contract(managerAddress, managerInterface)
    const skinKey = useContractCall({abi: managerInterface, address: managerAddress, method: "skinKey", args: [[addresses.summonerSkins, id.toString()]]})
    const assign = useContractFunction(managerContract,'assignSkinToSummoner')
    const [summonerId, setSummonerId] = useState(0)
    const classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"]

    let skinJson
    let imgUri
    if(skinBase64 !== undefined){
        skinJson = decodeURI(skinBase64)
        skinJson = skinJson.split("data:application/json;base64,").pop()
        skinJson = JSON.parse(atob(skinJson))
        imgUri = skinJson.image
    }

    return(
        <>
            {!skinBase64 && <div>Loading...&nbsp;</div>}
            {skinBase64 && <>
                <Card style={{ width: '15rem', margin: "0.2rem", paddingTop: "1rem"}} bg="dark">
                    <Card.Img src={imgUri}/>
                    <Card.Body>
                        <Card.Title>{skinJson.name}</Card.Title>
                        {skinClass && skinKey && <Card.Text>
                            {classes[skinClass - 1]}<br/>
                            {<Assignation skinKey={skinKey} managerAddress={managerAddress} />}
                        </Card.Text>}
                        {!skinClass && <Loading/>}
                        <Stack direction="horizontal">
                            <Form.Control size="sm" type="number" placeholder="summoner id" value=
                            {summonerId === 0 ? undefined : summonerId} 
                                onChange={e => setSummonerId(e.target.value)}/>
                            <Button size="sm" onClick={()=>{
                                assign.send(addresses.summonerSkins,id.toString(),summonerId)
                            }}>Assign</Button>
                        </Stack>
                    </Card.Body>
                </Card>
            </>}
        </>
    )
}

function Assignation({skinKey, managerAddress}){
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const assignation = useContractCall({abi: managerInterface, address: managerAddress, method: "summonerOf", args: [skinKey[0]]})

    if (!assignation) return <Loading/>
    if (assignation == 0) return <>unassigned</>
    else return <>skin of {assignation.toString()}</>
}