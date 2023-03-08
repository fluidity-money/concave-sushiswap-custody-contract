module.exports = {
  solidity: {
    version: "0.8.16",
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
        revertStrings: "debug",
      }
    },
  },
  etherscan: {
    apiKey: process.env.FLU_ETHERSCAN_API
  },
  docgen: {
    except: [`Interface`, `openzeppelin`],
  }
};
