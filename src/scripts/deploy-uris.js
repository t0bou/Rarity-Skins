const Web3 = require("web3")
const skinsJSON = require("../artifacts/contracts/SkinURIs.sol/SkinURIs.json")

async function main(){
    let web3 = await new Web3("http://localhost:8545")
    let accounts = await web3.eth.getAccounts()

    const skins = await deployContract(skinsJSON, accounts[0], web3, [5000])
    console.log(`skins deployed. tx hash : ${skins}`)
}

main()

// personnal library
async function sendContrFunc(stuffToDo, from, value){
    let gas = await stuffToDo.estimateGas({from: from, value: value})
    return await stuffToDo.send({from: from, gas: gas + 21000, gasPrice: '10000000000', value: value}) // price is 1 gwei
}

async function deployContract(json, from, web3, args){
    let contract = await new web3.eth.Contract(json.abi)
    return await sendContrFunc(contract.deploy({data:json.bytecode, arguments: args}), from)
}