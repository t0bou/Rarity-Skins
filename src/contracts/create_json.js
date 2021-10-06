const fs = require('fs')

async function main(){
    let skinURIs = fs.readFileSync("./SkinURIs.sol","utf8")
    const regex = /["].+["]/gm
    let arr = [...skinURIs.matchAll(regex)]
    arr = arr.map(el => el[0])
    arr = arr.map(str => str.slice(1,-1))

    writeTheFile(JSON.stringify(arr));
}

function writeTheFile(text){
  fs.writeFileSync(`./data.json`, text, err => {
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