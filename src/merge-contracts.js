const fs = require('fs')
const { merge } = require('sol-merger');

async function main(){
    let skins = await merge("./contracts/alts/SummonerSkins.sol")
    let uris = await merge("./contracts/alts/SkinURIs.sol")
    let manager = await merge("./contracts/alts/RaritySkinManager.sol")
    let fix = await merge("./contracts/alts/RaritySkinManagerFix.sol")

    let merges = [
      {name: 'skins', code : skins},
      {name: 'uris', code : uris},
      {name: 'manager', code : manager},
      {name: 'fix', code: fix}]
    let licenseLine = "//SPDX-License-Identifier: MIT\n"

    merges.forEach(_merged => {
      let lines = _merged.code.split('\n')
      lines = lines.filter(line => !line.includes("MIT"))
      let code = lines.join('\n')
      code = licenseLine + code
      writeTheFile(_merged.name,code)
    })
}

function writeTheFile(name, text){
  fs.writeFileSync(`./mergedSources/${name}.sol`, text, err => {
    if (err) {
      console.error(err)
      return
    }
  })
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })