
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./IUniswapV3Pool.sol";

interface IUniswapV3Factory {
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (IUniswapV3Pool pool);
}
