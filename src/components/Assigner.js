import * as managerJson from "../artifacts/contracts/RaritySkinManager.sol/RaritySkinManager.json"
import { useContractFunction } from "@usedapp/core"
import { ethers } from "ethers"
import { Form, Button } from "react-bootstrap"
import { useState } from "react"

export default function Assigner({managerAddress}){
    const managerABI = JSON.stringify(managerJson.abi)
    const managerInterface = new ethers.utils.Interface(managerABI)
    const managerContract = new ethers.Contract(managerAddress[0], managerInterface)
    const assign = useContractFunction(managerContract,'assignSkinToSummoner')
    const [summonerId, setSummonerId] = useState(0)
    const [tokenId, setTokenId] = useState(0)
    const [address, setAddress] = useState('')

    return(<>
        Assign any NFT as skin<br/>
        <div style={{display: "inline-block"}}>
            <Form.Control size="sm" type="number" placeholder="summoner id" value={summonerId !== 0 ? summonerId : undefined} onChange={e => setSummonerId(e.target.value)}/>
            <Form.Control size="sm" placeholder="NFT contract address" value={address !== '' ? address : undefined} onChange={e => setAddress(e.target.value)}/>
            <Form.Control size="sm" type="number" placeholder="NFT token id" value={tokenId !== 0 ? tokenId : undefined} onChange={e => setTokenId(e.target.value)}/>
            <Button onClick={()=>{
                assign.send(address,tokenId,summonerId)
            }}>Assign</Button>
        </div>
    </>)
}