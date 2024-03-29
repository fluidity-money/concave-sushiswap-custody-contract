
.PHONY: build clean test

all: build

ESCROW_OUT := artifacts/contracts/Escrow.sol/Escrow.json

build: ${ESCROW_OUT}

${ESCROW_OUT}: $(shell find contracts -type f)
	@npx hardhat compile

test:
	@npx hardhat --network forknet test

