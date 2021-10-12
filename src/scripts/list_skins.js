const Web3 = require("web3")
const skinsJSON = require("../artifacts/contracts/alts/SummonerSkins.sol/SummonerSkins.json")
const fs = require('fs')

async function main(){
    let web3 = await new Web3("https://rpc.ftm.tools/")

    let allSkinsData = []
    let tempJson
    let buff

    const skins = await new web3.eth.Contract(skinsJSON.abi, "0x6fEd400dA17f2678C450aA1D35e909653B3b482A")

    for(let i = 1; i <= 5000; i++){
        tempJson = await skins.methods.tokenURI(i).call()
        tempJson = decodeURI(tempJson)
        tempJson = tempJson.split("data:application/json;base64,").pop()
        buff = new Buffer(tempJson, 'base64')
        tempJson = JSON.parse(buff.toString('utf8'))
        console.log(tempJson.name)
        allSkinsData.push(tempJson)
    }

    fs.writeFileSync(`./allSkins.json`, JSON.stringify(allSkinsData), err => {
        if (err) {
          console.error(err)
          return
        }
    })

    console.log("done")
}

main()
.catch(err=>{
    console.log(err)
})