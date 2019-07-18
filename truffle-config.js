'use strict';

var HDWalletProvider = require("truffle-hdwallet-provider")

module.exports = {
  networks: {
    local: {
      host: 'localhost',
      port: 8545,
      gas: 7000000,
      gasPrice: 5e9,
      network_id: '*'
    },

    rinkeby: {
      provider: () => new HDWalletProvider(
        process.env.HDWALLET_MNEMONIC,
        process.env.INFURA_PROVIDER_URL_RINKBY,
        0, // we start with address[0]
        8 // notice that we unlock eight: which will be address[0] and address[1]
      ),
      network_id: 3,
      gas: 7000000,
      gasPrice: 1 * 1000000000
    }
  },

  compilers: {
    solc: {
      version: "0.5.0",
    }
  },

  solc: {
    optimizer: {
      enabled: true,
      runs: 1
    }
  }

};
