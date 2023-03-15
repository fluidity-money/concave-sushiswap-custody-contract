
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./INonfungiblePositionManager.sol";
import "./IERC20.sol";
import "./IUniswapV3Factory.sol";

// Escrow takes ERC20 tokens and mints them with Uniswap, remembering the
// amount of LP tokens that were received in exchange for the tokens
// given, and allows users to redeem the entire LP position associated
// with this contract in the future after a timestamp.

uint256 constant REDEEMABLE_SECONDS = 365 days;

int24 constant POSITION_TICK_LOWER = -887272;

int24 constant POSITION_TICK_UPPER = -POSITION_TICK_LOWER;

uint24 constant UNISWAP_MEDIUM_FEE = 3000;

contract Escrow {

    address private immutable allowedSender_;

    uint256 private redeemableBy_;

    INonfungiblePositionManager private immutable positionManager_;

    IERC20 private token0_;

    IERC20 private token1_;

    bool private uniswapInCallback_;

    constructor(
        address _allowedSender,
        INonfungiblePositionManager _positionManager,
        IERC20 _token0,
        IERC20 _token1
    ) {
        token0_ = _token1;
        token1_ = _token0;

        if (_token0 < _token1) {
            token0_ = _token0;
            token1_ = _token1;
        }

        allowedSender_ = _allowedSender;
        positionManager_ = _positionManager;
    }

    function transferAndSupply(
        uint256 _token0Amount,
        uint256 _token1Amount
    ) public returns (uint256) {
        require(msg.sender == allowedSender_, "only allowed sender");

        require(redeemableBy_ == 0, "already supplied");

        // take from the underlying user

        bool rc = token0_.transferFrom(
            msg.sender,
            address(this),
            _token0Amount
        );

        require(rc, "transfer from token 0 failed");

        rc = token1_.transferFrom(msg.sender, address(this), _token1Amount);

        require(rc, "transfer from token 1 failed");

        rc = token0_.approve(address(positionManager_), _token0Amount);

        require(rc, "failed to approve the position manager for token 0");

        rc = token1_.approve(address(positionManager_), _token1Amount);

        require(rc, "failed to approve the position manager for token 1");

        int24 tickSpacing =
            IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984)
              .getPool(address(token0_), address(token1_), 3000)
              .tickSpacing();

        MintParams memory params = MintParams({
            token0: address(token0_),
            token1: address(token1_),
            fee: UNISWAP_MEDIUM_FEE,
            tickLower: 60,
            tickUpper: 600,
            amount0Desired: _token0Amount,
            amount1Desired: _token1Amount,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(this),
            deadline: block.timestamp + 1 hours
        });

        (uint256 tokenId, uint256 liquidity, uint256 amount0, uint256 amount1) =
            positionManager_.mint(params);

        redeemableBy_ = block.timestamp + REDEEMABLE_SECONDS;

        return redeemableBy_;
    }

    function onERC721Received(
        address /* operator */,
        address,
        uint256 /* tokenId */,
        bytes calldata
    ) public returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
