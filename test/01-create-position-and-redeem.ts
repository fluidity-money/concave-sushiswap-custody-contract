
import * as hre from 'hardhat';

import type { ethers } from 'ethers';

import { expect } from 'chai';

const DEFAULT_NON_FUNGIBLE_POSITION_MANAGER =
  "0xC36442b4a4522E871399CD717aBDD847Ab11FE88";

const YEAR_PLUS_1 = 31536001;

const deploy = async (name: string, ...args: any[]): Promise<ethers.Contract> =>
  (await hre.ethers.getContractFactory(name))
    .deploy(...args);

describe("concave custody contract", async () => {
  it(
    "should create a pair of new tokens, supply it on uniswap, and redeem the entire position after a year",
    async () => {
      const rootSigner = (await hre.ethers.getSigners())[0];

      const rootSignerAddress = await rootSigner.getAddress();

      const startingBal = 100000;

      const liquidityAmount = 1000;

      const mockFluidUsdc = await deploy("ERC20", "Fluid USDC", "fUSDC", 18, startingBal);

      const mockUsdc = await deploy("ERC20", "USDC", "USDC", 6, startingBal);

      const escrow = await deploy(
        "Escrow",
        rootSignerAddress,
        DEFAULT_NON_FUNGIBLE_POSITION_MANAGER,
        mockFluidUsdc.address,
        mockUsdc.address
      );

      await mockFluidUsdc.approve(escrow.address, liquidityAmount);

      await mockUsdc.approve(escrow.address, liquidityAmount);

      await escrow.transferAndSupply(liquidityAmount, liquidityAmount);

      await hre.network.provider.send("evm_increaseTime", [YEAR_PLUS_1]);

      await escrow.redeem(rootSignerAddress);

      expect(await mockFluidUsdc.balanceOf(rootSignerAddress))
        .to.be.equal(startingBal);

      expect(await mockUsdc.balanceOf(rootSignerAddress))
        .to.be.equal(startingBal);
    }
  );

  it(
    "should take an existing pair of tokens, supply them on uniswap, redeem the entire position after a year and a half",
    async () => {

    }
  );
});
