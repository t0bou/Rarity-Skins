const Web3 = require("web3")
//const hre = require("hardhat")
const rarityAbi = require("../contracts/utils/rarity-abi.json")
const skinsJSON = require("../artifacts/contracts/SummonerSkins.sol/SummonerSkins.json")

async function main(){
    let web3 = await new Web3("http://localhost:8545")
    let rarity = await new web3.eth.Contract(rarityAbi, "0xce761D788DF608BD21bdd59d6f4B54b2e27F25Bb")
    let accounts = await web3.eth.getAccounts()

    let owner12 = await rarity.methods.ownerOf(12).call()
    console.log(owner12)

    const skins = await deployContract(skinsJSON, accounts[0], web3)
}

main()

// personnal library
async function sendContrFunc(stuffToDo, from, value){
    let gas = await stuffToDo.estimateGas({from: from, value: value})
    return await stuffToDo.send({from: from, gas: gas + 21000, gasPrice: '1000000000', value: value})
}

async function deployContract(json, from, web3, args){
    let contract = await new web3.eth.Contract(json.abi)
    return await sendContrFunc(contract.deploy({data:json.bytecode, arguments: args}), from)
}