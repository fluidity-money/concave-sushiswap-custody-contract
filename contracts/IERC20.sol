
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

interface IERC20 {
    function transferFrom(
        address _spender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function balanceOf(address _spender) external view returns (uint256);

    function transfer(address _spender, uint256 _amount) external returns (bool);
}
