import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-ethers";
import '@nomiclabs/hardhat-etherscan'
import dotenv from "dotenv";
dotenv.config()


const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.17',
    settings: {
      optimizer: {
        enabled: true,
      },
    },
  },
  networks: {
    hardhat: {
    },
    goerli: {
      url: `https://eth-goerli.g.alchemy.com/v2/omeWx9QBcpuXWiit2YNU7LAS8gpS-8lc`,
      accounts: [`0x${process.env.GOERLI_PRIVATE_KEY}`],
    },
    mumbai: {
      url: `https://polygon-mumbai.g.alchemy.com/v2/yKAz5XrIiuxswrPW7xiGx7dwcoJVSKLq`,
      accounts: [`0x${process.env.GOERLI_PRIVATE_KEY}`],
    },
  },
}


export default config;
