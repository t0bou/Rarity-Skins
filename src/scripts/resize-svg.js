const svge = require('svgexport')

function main(){
    svge.render("/Users/tobou/Downloads/LIVRABLEFIN/basique/chaussurescheap3.svg", e => console.log(e))
}

main()