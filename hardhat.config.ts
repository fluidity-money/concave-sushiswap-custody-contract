
import "@nomiclabs/hardhat-waffle";

const envForknetUrl = `FLU_ETHEREUM_FORKNET_URL_MAINNET`;

const forknetUrl = process.env[envForknetUrl];

if (forknetUrl === undefined || forknetUrl == "")
  throw new Error(`Forknet URL not supplied with ${envForknetUrl}`);

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
  networks: {
    forknet: {
      url: forknetUrl
    }
  },
  etherscan: {
    apiKey: process.env.FLU_ETHERSCAN_API
  },
  docgen: {
    except: [`Interface`, `openzeppelin`],
  }
};
