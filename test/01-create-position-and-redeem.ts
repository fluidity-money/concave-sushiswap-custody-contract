
import * as hre from 'hardhat';

import type { ethers } from 'ethers';

import { expect } from 'chai';

const YEAR_PLUS_100 = 31536100;

const deploy = async (name: string, ...args: any[]): Promise<ethers.Contract> =>
  (await hre.ethers.getContractFactory(name))
    .deploy(...args);

describe("concave custody contract", async () => {
  it(
    "should create a pair of new tokens, supply it on uniswap, and redeem the entire position after a year",
    async () => {
      const [rootSigner, secondSigner] = await hre.ethers.getSigners();

      const rootSignerAddress = await rootSigner.getAddress();

      const startingBal = 100000;

      const mockUsdc = await deploy("ERC20", "USDC", "USDC", 6, startingBal);

      const escrow = await deploy("Escrow", rootSignerAddress);

      await mockUsdc.transfer(escrow.address, startingBal);

      await expect(escrow.callStatic.redeem(mockUsdc.address))
        .to.be.revertedWith("not redeemable yet");

      await expect(escrow.connect(secondSigner).callStatic.redeem(mockUsdc.address))
        .to.be.revertedWith("not allowed sender");

      await hre.network.provider.send("evm_increaseTime", [YEAR_PLUS_100]);

      await escrow.redeem(mockUsdc.address);

      await expect(escrow.connect(secondSigner).callStatic.redeem(mockUsdc.address))
        .to.be.revertedWith("not allowed sender");

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
