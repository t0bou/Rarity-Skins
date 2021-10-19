const Web3 = require("web3")
const skinsJSON = require("../artifacts/contracts/alts/CommonSummonerSkins.sol/CommonSummonerSkins.json")
const uriJSON = require("../artifacts/contracts/alts/CommonSkinURIs.sol/CommonSkinURIs.json")
const managerJSON = require("../artifacts/contracts/alts/RaritySkinManagerFix.sol/RaritySkinManagerFix.json")
const artData = require("../contracts/alts/constructed.json")
const HDWalletProvider = require("@truffle/hdwallet-provider")
const secrets = require("../secrets.json")

async function main(){
    let provider = new HDWalletProvider({
        privateKeys: [secrets.privateKeys.fantom],
        providerOrUrl: secrets.RPCs.fantom
        //providerOrUrl: "http://localhost:8545"
    })

    let web3 = await new Web3(provider)
    let accounts = await web3.eth.getAccounts()

    const skins = await deployContract(skinsJSON, accounts[0], web3)
    console.log(skins.options.address);
    let manager = await new web3.eth.Contract(managerJSON.abi,"0xfFDFc7286c2c8d0a94f99c5e00dA1851564f8C1d")
    let uriAddress = await skins.methods.skinURIs().call()
    let uriContract = await new web3.eth.Contract(uriJSON.abi,uriAddress)
    let treatedData = []
    let arr
    for(let i = 0; i < artData.data.length; i++){
        arr = artData.data[i]
        treatedData.push(arr)
    }

    await sendContrFunc(uriContract.methods.initializeArt(0,treatedData.slice(0,3)),accounts[0])
    await sendContrFunc(uriContract.methods.initializeArt(3,treatedData.slice(3,8)),accounts[0])
    await sendContrFunc(uriContract.methods.initializeArt(8,treatedData.slice(8,treatedData.length)),accounts[0])
    await sendContrFunc(uriContract.methods.renounceOwnership(),accounts[0])
    await sendContrFunc(manager.methods.trustImplementation(skins.options.address), accounts[0])

    console.log("done")
}

main()
.then(()=>{process.exit(0)})
.catch(err=>{
    console.log(err)
})

// personnal library
async function sendContrFunc(stuffToDo, from, value){
    let gas = await stuffToDo.estimateGas({from: from, value: value})
    console.log(gas)
    return await stuffToDo.send({from: from, gas: gas + 21000, gasPrice: '400000000000', value: value})
}

async function deployContract(json, from, web3, args){
    let contract = await new web3.eth.Contract(json.abi)
    return await sendContrFunc(contract.deploy({data:json.bytecode, arguments: args}), from)
}