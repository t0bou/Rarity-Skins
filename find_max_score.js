const skins = require("./allSkins.json")
const stats = require("./src/rare_skins_stats.json")

function main(){
    let maxScore = 0
    let tempScore
    let score = 0
    let skinName
    let j = 0

    skins.forEach(skin => {
        skin.attributes.forEach(attr => {
            tempScore = stats[attr.trait_type][attr.value]
            tempScore = tempScore.slice(0,-1)
            tempScore = 100 - parseFloat(tempScore)
            score += tempScore
        })
        skinName = score > maxScore ? skin.name : skinName
        maxScore = score > maxScore ? score : maxScore
        if(score > 457.5){
            console.log(skin.name);
            j++
        }
        score = 0
    })
    console.log(maxScore, skinName, j)
}

main()