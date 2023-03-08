
// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;

import "./IERC20.sol";
import "./INonfungiblePositionManager.sol";

// Escrow takes ERC20 tokens and mints them with Uniswap, remembering the
// amount of LP tokens that were received in exchange for the tokens
// given, and allows users to redeem the entire LP position associated
// with this contract in the future after a timestamp.

uint256 constant REDEEMABLE_SECONDS = 365 days;

address constant ALLOWED_SENDER = 0x6221A9c005F6e47EB398fD867784CacfDcFFF4E7;

int24 constant POSITION_TICK_LOWER = 0;

int24 constant POSITION_TICK_UPPER = 0;

contract Escrow {
    event LiquidityProvided(
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    event LiquidityDecreased(
        uint256 fluidDraining,
        uint256 usdcDraining
    );

    address private immutable allowedSender_;

    uint256 private redeemableBy_;

    INonfungiblePositionManager private immutable positionManager_;

    IERC20 private immutable fluidUnderlying_;

    IERC20 private immutable usdcUnderlying_;

    uint256 private tokenId_;

    uint256 private fluidSupplied_;

    uint256 private usdcSupplied_;

    constructor(
    	address _allowedSender,
        INonfungiblePositionManager _positionManager,
        IERC20 _fluidUnderlying,
        IERC20 _usdcUnderlying
    ) {
    	allowedSender_ = _allowedSender;
        positionManager_ = _positionManager;
        fluidUnderlying_ = _fluidUnderlying;
        usdcUnderlying_ = _usdcUnderlying;
    }

    function transferAndSupply(
        uint256 _fluidAmount,
        uint256 _usdcAmount
    ) public {
        require(msg.sender == allowedSender_, "only allowed sender");

        require(redeemableBy_ != 0, "already supplied");

        // take from the underlying user

        bool rc = fluidUnderlying_.transferFrom(address(this), msg.sender, _fluidAmount);

        require(rc, "transfer from fluid failed");

        rc = usdcUnderlying_.transferFrom(address(this), msg.sender, _usdcAmount);

        require(rc, "transfer from usdc failed");

        rc = fluidUnderlying_.approve(address(this), _fluidAmount);

        require(rc, "failed to approve nonfungible for fusdc");

        rc = usdcUnderlying_.approve(address(this), _usdcAmount);

        require(rc, "failed to approve nonfungible for usdc");

        // supply assets to uniswap

        (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amount0,
            uint256 amount1
        ) = positionManager_.mint(MintParams({
            token0: address(fluidUnderlying_),
            token1: address(usdcUnderlying_),
            fee: 0,
            tickLower: POSITION_TICK_LOWER,
            tickUpper: POSITION_TICK_UPPER,
            amount0Desired: _fluidAmount,
            amount1Desired: _usdcAmount,
            amount0Min: _fluidAmount,
            amount1Min: _usdcAmount,
            recipient: address(this),
            deadline: block.timestamp
        }));

        tokenId_ = tokenId;

        fluidSupplied_ = _fluidAmount;

        usdcSupplied_ = _usdcAmount;

        emit LiquidityProvided(
            tokenId,
            liquidity,
            amount0,
            amount1
        );

        redeemableBy_ = block.timestamp + REDEEMABLE_SECONDS;
    }

    function onERC721Received(
        address _operator,
        address /* _from */,
        uint256 /* tokenId */,
        bytes calldata /* data */
    ) public {
        // do nothing
        // solhint-disable-empty-lines
    }

    function redeem(address _to) public {
    	require(msg.sender == allowedSender_);

    	(,,,,,,, uint128 liquidity,,,,) = positionManager_.positions(tokenId_);

    	emit LiquidityDecreased(fluidSupplied_, usdcSupplied_);

    	(
    	    uint256 amount0,
    	    uint256 amount1
    	) = positionManager_.decreaseLiquidity(DecreaseLiquidityParams({
    	    tokenId: tokenId_,
    	    liquidity: liquidity,
    	    amount0Min: fluidSupplied_,
    	    amount1Min: fluidSupplied_,
    	    deadline: block.timestamp
    	}));

    	uint256 fluidBalance = fluidUnderlying_.balanceOf(address(this));

    	require(fluidBalance > 0, "fluid balance = 0");

    	uint256 usdcBalance = fluidUnderlying_.balanceOf(address(this));

    	require(usdcBalance > 0, "usdc balance = 0");

    	bool rc = fluidUnderlying_.transfer(_to, fluidBalance);

    	require(rc, "failed to transfer fusdc the address given");

    	rc = usdcUnderlying_.transfer(_to, usdcBalance);

    	require(rc, "failed to transfer usdc to the address given");

    	if (fluidSupplied_ <= amount0) {
    	    fluidSupplied_ = 0;
    	} else {
            fluidSupplied_ -= amount0;
    	}

         if (usdcSupplied_ <= amount1) {
             usdcSupplied_ = 0;
         } else {
    	    usdcSupplied_ -= amount1;
         }
    }
}
