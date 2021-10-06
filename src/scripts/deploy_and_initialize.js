const Web3 = require("web3")
const skinsJSON = require("../artifacts/contracts/alts/SummonerSkins.sol/SummonerSkins.json")
const uriJSON = require("../artifacts/contracts/alts/SkinURIs.sol/SkinURIs.json")
const artData = require("../contracts/alts/data.json")

async function main(){
    let web3 = await new Web3("http://localhost:8545")
    let accounts = await web3.eth.getAccounts()

    const skins = await deployContract(skinsJSON, accounts[0], web3)
    let uriAddress = await skins.methods.skinURIs().call()
    let uriContract = await new web3.eth.Contract(uriJSON.abi,uriAddress)
    let treatedData = []
    const regex = /["'"]/gm
    let arr
    for(let i = 0; i < artData.data.length; i++){
        arr = artData.data[i]
        arr = arr.map(str => str.replace((regex, str => {
                return str === '"' ? "'" : '"'
            })))
        treatedData.push(arr)
    }

    await sendContrFunc(uriContract.methods.initializeArt(0,treatedData.slice(0,3)),accounts[0])
    await sendContrFunc(uriContract.methods.initializeArt(3,treatedData.slice(3,8)),accounts[0])
    await sendContrFunc(uriContract.methods.initializeArt(8,treatedData.slice(8,treatedData.length)),accounts[0])
    await sendContrFunc(uriContract.methods.renounceOwnership(),accounts[0])

    console.log("done")
}

main()
.catch(err=>{
    console.log(err)
})

// personnal library
async function sendContrFunc(stuffToDo, from, value){
    let gas = await stuffToDo.estimateGas({from: from, value: value})
    console.log(gas)
    return await stuffToDo.send({from: from, gas: gas + 21000, gasPrice: '1000000000', value: value}) // gas fee is 1 gwei
}

async function deployContract(json, from, web3, args){
    let contract = await new web3.eth.Contract(json.abi)
    return await sendContrFunc(contract.deploy({data:json.bytecode, arguments: args}), from)
}