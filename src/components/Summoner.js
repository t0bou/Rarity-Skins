import { useContractCall } from "@usedapp/core"
import { ethers } from "ethers"
import * as summonerSkinsJson from "../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json"
import * as managerJson from "../artifacts/contracts/RaritySkinManager.sol/RaritySkinManager.json"
import * as rarityABI from "../dependencies/RarityABI.json"
import Loading from "./Loading"
import emptyImg from "../dependencies/empty.png"
import { Card } from "react-bootstrap"
import LoadingGif from "../dependencies/loading.gif"
import { useEffect, useState } from "react"

export default function Summoner({id, managerAddress}){
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const skinStruct = useContractCall({abi : managerInterface, address: managerAddress[0], method: "skinOf", args: [id]})
    
    return(
        <>
            {!skinStruct && <Loading/>}
            {skinStruct && <_Summoner id={id} skinId={skinStruct[1].toNumber()} skinAddress={skinStruct[0]} />}
        </>
    )
}

function _Summoner({id, skinId, skinAddress}){
    const rarityAddress = '0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb'
    const classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"]
    const rarityInterface = new ethers.utils.Interface(JSON.stringify(rarityABI.default))
    const summonerClass = useContractCall({abi: rarityInterface, address: rarityAddress, method: 'class', args: [id.toString()]})

    return(
        <>
            {!summonerClass && <div>Loading...&nbsp;</div>}
            {summonerClass && skinId === 0 && 
            <Card style={{ width: '15rem', margin: "0.2rem", paddingTop: "1rem"}} bg="dark">
                <Card.Img src={emptyImg}/>
                <Card.Body>
                    <Card.Title>{classes[summonerClass - 1]}</Card.Title>
                    <Card.Text>
                        {id}
                        <br/>no skin
                    </Card.Text>
                </Card.Body>
            </Card>}
            {summonerClass && skinId !== 0 && <_SummonerWithSkin summonerClass={summonerClass} skinAddress={skinAddress} skinId={skinId} id={id} />}
        </>
    )
}

function _SummonerWithSkin({summonerClass, skinAddress, id, skinId}){
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const tokenURI = useContractCall({abi : skinsInterface, address: skinAddress, method: "tokenURI", args: [skinId]})

    return(<>
        {!tokenURI && <div>Loading...&nbsp;</div>}
        {tokenURI && <_SummonerWithData summonerClass={summonerClass} tokenURI={tokenURI} id={id} />}
    </>)
}

function _SummonerWithData({summonerClass, tokenURI, id}){
    const classes = ["Barbarian", "Bard", "Cleric", "Druid", "Fighter", "Monk", "Paladin", "Ranger", "Rogue", "Sorcerer", "Wizard"]
    const [img, setImg] = useState(undefined)
    const [name, setName] = useState(undefined)

    useEffect(() => {
        fetch(tokenURI)
            .then(res => res.json().then(json => {
                setImg(json.image)
                setName(json.name)
            }))
    },[tokenURI])

    return(
        <>
            {(!img || !name) && <div>Loading...&nbsp;</div>}
            {img && name && <>
                <Card style={{ width: '15rem', margin: "0.2rem", paddingTop: "1rem"}} bg="dark">
                    <Card.Img src={img} />
                    <Card.Body>
                        <Card.Title>{classes[summonerClass - 1]}</Card.Title>
                        <Card.Text>
                            {id}
                            <br/>{name}
                        </Card.Text>
                    </Card.Body>
                </Card>
            </>}
        </>
    )
}