const fs = require('fs')

async function main(){
    let skinURIs = fs.readFileSync("./SkinURIs.sol","utf8")
    const regex = /["'"]/gm
    skinURIs = skinURIs.replace(regex, str => {
        return str === '"' ? "'" : '"'
    });
    writeTheFile(skinURIs)
}

function writeTheFile(text){
  fs.writeFileSync(`./SkinURIs.sol`, text, err => {
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