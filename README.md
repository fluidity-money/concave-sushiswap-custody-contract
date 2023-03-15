
# Concave Escrow Contract

Remembers an allowed recipient and a time that ERC20 tokens can be
redeemed by (default 365 days in the future).

ERC20 tokens that are transferred to this contract can be redeemed
following the redemption date to a recipient.

## Usage

### Redemption

	redeem(address token)

Uses the token address given and sends to the recipient stored by the
constructor.
