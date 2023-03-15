
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./IERC20.sol";

uint256 constant REDEEMABLE_SECONDS = 365 days;

contract Escrow {

    event Redeemed(address indexed sender, uint256 amount);

    address private immutable allowedSender_;

    uint256 private immutable redeemableBy_;

    bool private lock_;

    constructor(address _allowedSender) {
        redeemableBy_ = block.timestamp + REDEEMABLE_SECONDS;
        allowedSender_ = _allowedSender;
    }

    function redeem(IERC20 _asset) public {
        require(!lock_, "reentrant");

        require(msg.sender == allowedSender_, "not allowed sender");

        require(block.timestamp > redeemableBy_, "not redeemable yet");

        lock_ = true;

        uint256 balance = _asset.balanceOf(address(this));

        emit Redeemed(address(_asset), balance);

        bool rc = _asset.transfer(msg.sender, balance);

        require(rc, "transfer failed");

        lock_ = false;
    }
}
