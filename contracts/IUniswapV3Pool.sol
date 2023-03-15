
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IUniswapV3Pool {
   function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    function tickSpacing() external view returns (int24);

    function initialize(uint160 sqrtPriceX96) external;
}
