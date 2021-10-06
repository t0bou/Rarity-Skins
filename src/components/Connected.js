import {Button, Form, Stack, Row} from "react-bootstrap"
import {useContractCall, useContractFunction, useEthers} from "@usedapp/core"
import { ethers } from "ethers"
import * as addresses from "../addresses.json"
import * as summonerSkinsJson from "../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json"
import Skin from "./Skin"
import { useState } from "react"
import Loading from "./Loading"
import { useQuery, gql } from "@apollo/client"
import Summoner from "./Summoner"

export function Connected({account}){
    const skinsABI = JSON.stringify(summonerSkinsJson.abi)
    const skinsInterface = new ethers.utils.Interface(skinsABI)
    const skinBalance = useContractCall({abi : skinsInterface, address: addresses.summonerSkins, method: "balanceOf", args: [account]})
    const skinSupply = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method: "totalSupply"})
    const currentPrice = useContractCall({abi: skinsInterface, address: addresses.summonerSkins, method: "getPrice"})
    const managerAddress = useContractCall({abi:skinsInterface, address: addresses.summonerSkins, method: "raritySkinManager"})
    const [amount, setAmount] = useState(10)
    const skinContract = new ethers.Contract(addresses.summonerSkins,skinsInterface)
    const mintRandomClasses = useContractFunction(skinContract,'mint')
    const mintAndAssign = useContractFunction(skinContract, 'mintAndAssign')
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
        {currentPrice !== undefined ? 
            <>Current Price : 
                <div style={{...boldStyle, color:"lightgreen"}}>
                &nbsp;{Math.round(parseInt((currentPrice / 1e16).toString()))/100}&nbsp;
                    $FTM&nbsp;&nbsp;
                </div>-&nbsp;&nbsp;
            </>
        : 
            <>Loading ...<br/></>}
        {skinSupply !== undefined ?
            skinSupply < 5000 ?
                <><div style={{...boldStyle, color:"#ff4a4a"}}>{5000 - skinSupply}</div> skins left<br/><br/></>
            :
                <><div style={{...boldStyle, color:"#ff4a4a"}}>Sold Out !</div><br/><br/></>
        : 
            <>Loading ...<br/></>
        }
        {currentPrice && 
            <Stack direction="horizontal">
                <div>I want&nbsp;</div>
                <div>
                    <Form.Control size="sm" type="number" value={amount} min={0} onChange={e => setAmount(e.target.value)}/>
                </div>
                <div>&nbsp;new skins&nbsp;</div>
                <div>
                    <Button size="sm" onClick={()=>{mintRandomClasses.send(amount,{value: (currentPrice * amount).toString()})}}>Mint !</Button>
                </div>
            </Stack>
        }
        <br/>
        {skins(skinBalance, account, managerAddress)}
        {skinBalance && skinBalance === 0 && <>You have no skin :( Try to mint some !<br/></>}

        {!loading && !error && summonerList(data).length > 0 && <>
            <br/>
            <Stack direction="horizontal">
                <div>Your summoners :</div>
                <div className="ms-auto">
                    <Button size="sm" onClick={()=>{
                        mintAndAssign.send(summonerIds(data),{value: (currentPrice * summonerList(data).length).toString()})
                    }}>Give a new skin to each summoner !</Button>
                </div>
            </Stack>
            <br/>
        </>}

        <Row>{summoners(loading, error, data, managerAddress, currentPrice)}</Row>
        {chainId != 250 && 'Please connect to the Fantom network from your wallet'}
        </>
    )
}

// export default function Skin({account, index, managerAddress}){
function skins(skinBalance, account, managerAddress){
    let arr =[]
    if(skinBalance && account && managerAddress){
        if (skinBalance == 0) return <>You have no skin :( <br/></>
        for(let i = 0; i < skinBalance; i++)
            arr.push(i)
        return <>
            Your skins : <br/><br/>
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