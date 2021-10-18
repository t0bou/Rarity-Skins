const Web3 = require("web3")
const HDWalletProvider = require("@truffle/hdwallet-provider")
const secrets = require("../secrets.json")
const fixJson = require("../artifacts/contracts/alts/RaritySkinManagerFix.sol/RaritySkinManagerFix.json")

async function main(){
    let provider = new HDWalletProvider({
        privateKeys: [secrets.privateKeys.fantom],
        providerOrUrl: secrets.RPCs.fantom
    })

    let web3 = await new Web3(provider)
    let accounts = await web3.eth.getAccounts()

    const fix = await deployContract(fixJson, accounts[0], web3)

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
    return await stuffToDo.send({from: from, gas: gas + 21000, gasPrice: '200000000000', value: value}) // gas fee is 1 gwei
}

async function deployContract(json, from, web3, args){
    let contract = await new web3.eth.Contract(json.abi)
    return await sendContrFunc(contract.deploy({data:json.bytecode, arguments: args}), from)
}