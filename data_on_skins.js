const { log } = require('console');
const fs = require('fs')

async function main(){
    const types =  ['Accessory','Weapon','Head','Shoes','Torso']

    let attributes = {
        Accessory:{},
        Weapon: {},
        Head: {},
        Shoes: {},
        Torso: {},
        Accessory_count: 0,
        Weapon_count: 0,
        Head_count: 0,
        Shoes_count: 0,
        Torso_count: 0,
        0: 0,
        1: 0,
        2: 0,
        3: 0,
        4: 0,
        5: 0
    }

    let skins = fs.readFileSync("./allSkins.json",{encoding:'utf8'})

    skins = JSON.parse(skins)
    skins.forEach(element => {
        attributes[Object.keys(element.attributes).length] += 1
        element.attributes.forEach(attribute => {
            attributes[attribute.trait_type + "_count"] += 1
            if (!attributes[attribute.trait_type][attribute.value]){
                attributes[attribute.trait_type] = {...attributes[attribute.trait_type], [attribute.value]: 0}
            }
            attributes[attribute.trait_type][attribute.value] += 1
        })
    })
    for(let i = 0; i <= 5; i++){
        attributes[i] = ((Math.round((attributes[i] / 5000) * 1000))/10).toString() + '%'
    }
    types.forEach(type => {
        attributes[type + "_count"] = ((Math.round((attributes[type + "_count"] / 5000) * 1000))/10).toString() + '%'
        for(el in attributes[type]){
            attributes[type][el] = ((Math.round((attributes[type][el] / 5000) * 1000))/10).toString() + '%'
        }
    })
    log(attributes)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    })