
import "@nomiclabs/hardhat-waffle";

module.exports = {
  solidity: {
    compilers: [
      { version: "0.8.16" },
      { version: "0.7.6" }
    ],
    settings: {
      optimizer: {
        enabled: true,
        runs: 10000000,
        details: {
          cse: true,
          yul: true,
        }
      },
      debug: {
        revertStrings: "*",
      }
    },
  },
  networks: {
    localhost: {
      url: "http://127.0.2.1:8545"
    }
  },
  etherscan: {
    apiKey: process.env.FLU_ETHERSCAN_API
  },
  docgen: {
    except: [`Interface`, `openzeppelin`],
  }
};
