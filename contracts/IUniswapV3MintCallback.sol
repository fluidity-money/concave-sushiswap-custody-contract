
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IUniswapV3MintCallback {
    function uniswapV3MintCallback(
      uint256 amount0Owed,
      uint256 amount1Owed,
      bytes memory data
    ) external;
}
