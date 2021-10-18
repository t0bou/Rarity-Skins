import { Form, Stack, Row} from "react-bootstrap"
import {useContractCall, useEthers} from "@usedapp/core"
import { ethers } from "ethers"
import * as addresses from "../addresses.json"
import * as summonerSkinsJson from "../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json"
import Skin from "./Skin"
import { useState } from "react"
import Loading from "./Loading"
import { useQuery, gql } from "@apollo/client"
import Summoner from "./Summoner"
import SkinInfos from "./SkinInfos"
import Assigner from "./Assigner"

export function Connected({account}){
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const skinBalance = useContractCall({abi : skinsInterface, address: addresses.summonerSkins, method: "balanceOf", args: [account]})
    const currentPrice = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method: "getPrice"})
    const managerAddress = [addresses.manager];
    const [skinId, setSkinId] = useState(0)
    const {loading, error, data} = useQuery(gql`{
        summoners(where: {owner:"${account.toLowerCase()}"}) {
            id
        }
    }`)
    const {chainId} = useEthers()

    const boldStyle = {fontWeight: "bold", display: "inline-block"}
    
    // 250 is fantom's chain id
    return(
        <>
        <br/>
        Connected to {account.substring(0,5) + '...' + account.substring(account.length - 3)} <br/><br/>
        Rare Skins are <div style={{...boldStyle, color:"#ff4a4a"}}>Sold Out</div> !<br/>
        Find them on <a href="https://paintswap.finance/marketplace/collections/0x6fed400da17f2678c450aa1d35e909653b3b482a">PaintSwap</a> 
        &nbsp;or <a href="https://artion.io/explore">Artion</a><br/>
        <br/>
        Get infos on a Rare Skin <div style={{display: "inline-block"}}>
            <Form.Control size="sm" type="number" placeholder="skin id" value={skinId !== 0 ? skinId : undefined} onChange={e => setSkinId(e.target.value)}/>
        </div>
        {skinId > 0 && skinId <= 5000 && managerAddress && <><br/><br/><SkinInfos id={skinId} managerAddress={managerAddress}/></>}
        <br/><br/>
        {managerAddress && <Assigner managerAddress={managerAddress} />}
        <br/><br/>
        {skins(skinBalance, account, managerAddress)}
        {skinBalance && skinBalance === 0 && <>You have no skin :( Try to mint some !<br/></>}

        {!loading && !error && summonerList(data).length > 0 && <>
            <br/>
            <Stack direction="horizontal">
                <div>Your Summoners :</div>
            </Stack>
            <br/>
        </>}

        <Row>{summoners(loading, error, data, managerAddress, currentPrice)}</Row>
        {chainId != 250 && 'Please connect to the Fantom network from your wallet'}
        </>
    )
}

function skins(skinBalance, account, managerAddress){
    let arr =[]
    if(skinBalance && account && managerAddress){
        if (skinBalance == 0) return <>You have no skin :( <br/></>
        for(let i = 0; i < skinBalance; i++)
            arr.push(i)
        return <>
            Your Rare Skins : <br/><br/>
            <Row>{arr.map(index => <Skin key={index} index={index} account={account} managerAddress={managerAddress[0]}/>)}</Row>
        </>
    } else {
        return <Loading/>
    }
}

function summoners(loading, error, data, managerAddress, currentPrice){
    let summonerList;

    if (loading) return <Loading/>
    if (error) return <>GraphQL Error :( unable to load summoners</>
    if (data && managerAddress && currentPrice){
        summonerList = data.summoners
        if (summonerList.length == 0){
            return <>You have no summoners :( <br/></>
        } else {
            return summonerList.map(summoner => <Summoner id={parseInt(summoner.id)} key={parseInt(summoner.id)} price={currentPrice} managerAddress={managerAddress}/>)
        }
    }
}

function summonerIds(data){
    return data.summoners.map(summoner => parseInt(summoner.id))
}

function summonerList(data){
    return data.summoners
}