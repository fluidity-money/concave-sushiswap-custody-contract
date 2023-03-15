
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./IERC20.sol";

uint256 constant REDEEMABLE_SECONDS = 365 days;

contract Escrow {

    event Redeemed(
        address indexed recipient,
        address indexed token,
        uint256 amount
    );

    address public immutable recipient_;

    uint256 public immutable redeemableBy_;

    bool private lock_;

    constructor(address _recipient) {
        redeemableBy_ = block.timestamp + REDEEMABLE_SECONDS;
        recipient_ = _recipient;
    }

    function redeem(IERC20 _asset) public {
        require(!lock_, "reentrant");

        require(block.timestamp > redeemableBy_, "not redeemable yet");

        lock_ = true;

        uint256 balance = _asset.balanceOf(address(this));

        emit Redeemed(recipient_, address(_asset), balance);

        bool rc = _asset.transfer(recipient_, balance);

        require(rc, "transfer failed");

        lock_ = false;
    }
}
