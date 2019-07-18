const fs = require('fs')

const PoolState = artifacts.require('PoolState.sol')

module.exports = function(deployer, networkName, accounts) {
  deployer.then(async () => {
    const poolState = await PoolState.deployed()

    const json = JSON.parse(fs.readFileSync('./boughtTicketEvents.json'))

    for (i = 0; i < json.length; i++) {
        const BoughtTicket = json[i]
        const { from, count } = BoughtTicket
        console.log(`buyTickets(${from}, ${count.toString()})`);
        await poolState.buyTickets(from, count);
    }
    console.log('')
    console.log(`The false winner was: ${await poolState.falseWinnerAddress()}`)
    console.log(`The true winner is: ${await poolState.winnerAddress()}`)
  })
};
