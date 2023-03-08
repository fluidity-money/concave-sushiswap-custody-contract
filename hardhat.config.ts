
const envForknetUrl = `FLU_ETHEREUM_FORKNET_URL_MAINNET`;

const forknetUrl = process.env[envForknetUrl];

if (forknetUrl === undefined || forknetUrl == "")
  throw new Error(`Forknet URL not supplied with ${envForknetUrl}`);

module.exports = {
  solidity: {
    version: "0.8.16",
    networks: {
      forknet: {
        url: forknetUrl
      }
    },
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
