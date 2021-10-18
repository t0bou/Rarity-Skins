const skins = require("./allSkins.json")
const stats = require("./src/rare_skins_stats.json")
const fs = require('fs')
const { log } = require("console")

function main(){
    let maxScore = 0
    let tempScore
    let score = 0
    let skinName
    let j = 0
    let scoreRanking = []

    skins.forEach(skin => {
        skin.attributes.forEach(attr => {
            tempScore = stats[attr.trait_type][attr.value]
            tempScore = tempScore.slice(0,-1)
            tempScore = 100 - parseFloat(tempScore)
            score += tempScore
        })
        scoreRanking.push({id : parseInt(skin.name.substring(11, skin.name.length)), score : Math.round(score * 10)/10})

        skinName = score > maxScore ? skin.name : skinName
        maxScore = score > maxScore ? score : maxScore
        if(score > 457.5){
            console.log(skin.name);
            j++
        }
        score = 0
    })
    scoreRanking = scoreRanking.sort((a,b) => {
        if(a.score !== b.score)
            return b.score - a.score
        else
            return a.id - b.id
    })
    fs.writeFileSync("scoreRanks.json",JSON.stringify(scoreRanking.map(el => el.id)),'utf-8')
    console.log(scoreRanking[0], scoreRanking[1], scoreRanking[2], scoreRanking[3], scoreRanking[scoreRanking.length - 1], scoreRanking[scoreRanking.length - 2], scoreRanking[scoreRanking.length - 3])
}

main()