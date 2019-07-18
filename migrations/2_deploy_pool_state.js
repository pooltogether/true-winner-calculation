// 1_initial_migration.js
const shell = require('shelljs')

module.exports = function(deployer, networkName, accounts) {
  deployer.then(async () => {
    
    const secret = '0xedd12d59f65c22797103a883c9eb4b624f9445dccda427dc7c25b86d3888ed42'
    const blockHash = '0x29dd428018a26e8dc2ff6ebcd2a25a176b73c2564d021534b6b1d289412970ab'
    const ticketPrice = web3.utils.toWei('20', 'ether')
    const owner = accounts[0]

    if (shell.exec(`zos create PoolState --init init --args ${secret},${blockHash},${ticketPrice},${owner} --network ${networkName} --from ${process.env.ADMIN_ADDRESS}`).code !== 0) {
      throw new Error('Migration failed')
    }
  })
};
