
import * as hre from 'hardhat';

import { BigNumber } from 'ethers';

import type { ethers } from 'ethers';

import { expect } from 'chai';

const DEFAULT_UNISWAP_V3_FACTORY =
  "0x1F98431c8aD98523631AE4a59f267346ea31F984";

const DEFAULT_UNISWAP_NONFUNGIBLE_POSITION_MANAGER =
  "0xc36442b4a4522e871399cd717abdd847ab11fe88";

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

      const mockUsdc = await deploy("ERC20", "USDC", "USDC", 6, startingBal);

      const mockFluidUsdc = await deploy(
        "ERC20",
        "Fluid USDC",
        "fUSDC",
        18,
        startingBal
      );

      const uniswapFactory = await hre.ethers.getContractAt(
        "IUniswapV3Factory",
        DEFAULT_UNISWAP_V3_FACTORY
      );

      expect(await uniswapFactory.callStatic.getPool(mockFluidUsdc.address, mockUsdc.address, 3000))
        .to.be.equal("0x0000000000000000000000000000000000000000");

      const pool_ = await uniswapFactory.callStatic.createPool(
        mockFluidUsdc.address,
        mockUsdc.address,
        3000
      );

      console.log("creating pool");

      await uniswapFactory.createPool(
        mockFluidUsdc.address,
        mockUsdc.address,
        3000
      );

      console.log("pool created");

      const pool = await hre.ethers.getContractAt("IUniswapV3Pool", pool_);

      // (* (sqrt 1) (pow 2 96)) (as per https://github.com/Uniswap/v3-periphery/blob/19359e1254070b438003a71ba414811083ef39ce/test/shared/encodePriceSqrt.ts#L7)

      await pool.initialize(BigNumber.from("79228162514264337593543950336"));

      console.log("about to deploy");

      const escrow = await deploy(
        "Escrow",
        rootSignerAddress,
        DEFAULT_UNISWAP_NONFUNGIBLE_POSITION_MANAGER,
        mockFluidUsdc.address,
        mockUsdc.address
      );

      await mockFluidUsdc.approve(escrow.address, BigNumber.from("100000000000000000"));

      await mockUsdc.approve(escrow.address, BigNumber.from("100000000000000000"));

      console.log("about to transfer");

      const timestamp =
        await escrow.callStatic.transferAndSupply(liquidityAmount, liquidityAmount);

      console.log(`timetsamp: ${timestamp}`);

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
