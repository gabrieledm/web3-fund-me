# Import '.env' file
-include .env

# Install foundry modules
install:
	forge install cyfrin/foundry-devops@0.2.3 && \
    forge install smartcontractkit/chainlink-brownie-contracts@1.2.0 && \
    forge install foundry-rs/forge-std@v1.9.3
# Remove foundry modules
remove:
	rm -rf lib

# Build the project
# ; is to write the command in the same line
build:; forge build
build-force:; forge build --force

test-simple:; forge test
test-verbose:; forge test -vvv

anvil:;	anvil

deploy-test:; forge script script/FundMe.s.sol:FundMeScript
deploy-anvil:
	forge script script/FundMe.s.sol:FundMeScript \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
	--broadcast
deploy-sepolia:
	forge script script/FundMe.s.sol:FundMeScript \
    --rpc-url $(SEPOLIA_RPC_URL) \
    --private-key $(SEPOLIA_PRIVATE_KEY) \
	--broadcast \
    --verify \
    --etherscan-api-key $(ETHERSCAN_API_KEY)