## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

- Simple
  ```shell
  $ forge test
  ```
- Verbose
  ```shell
  $ forge test -vvvv
  ```
  - The more `v` will be used (for a maximum of 4), the more verbosity output will be printed 
- Run specific test
  ```shell
  forge test --match-test <regex>
  ```
  - Example
    ```shell
    forge test --match-test testPriceFeedVersionIsAccurate
    ```
- Run test on a forked chain
  ```shell
  forge test --fork-url <your_forked_chain_rpc_url>
  ```
  - Example
    ```shell
    forge test --fork-url $SEPOLIA_RPC_URL
    ```
- Run test with coverage
  ```shell
  forge coverage
  ```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Inspect Contract

- Inspect the `storage layout` of a contract
  ```bash
  forge inspect <contract_name> storageLayout
  ```
  - Example
    ```bash
    forge inspect FundMe storageLayout
    ```
  
### Anvil

```shell
$ anvil
```

### Deploy

- Simple
  ```shell
  $ forge script script/FundMe.s.sol:FundMeScript --rpc-url <your_rpc_url> --private-key <your_private_key>
  ```
- Build deploy transaction without sent it (test if the script goes well)
  ```shell
  forge script script/FundMe.s.sol:FundMeScript
  ```
- Deploy `FundMe` contract and the related `Interactions:FundFundMe` contract
  ```bash
  forge script script/FundMe.s.sol \
    --force \
    --broadcast \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
  forge script script/Interactions.s.sol:FundFundMe \
    --force \
    --broadcast \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
  ```

### Cast

```shell
$ cast <subcommand>
```

- Get the contract's storage at specified slot
  ```bash
  cast storage <contract_address> <storage_slot_number>
  ```
- Get the function's selector
  ```bash
  cast sig "<function-signature>"
  ```
  - Example
    ```bash
    cast sig "getAddressToAmountFunded(address)" 
    ```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```

### Install dependencies

- *Chainlink*
  - Latest version
    ```shell
    forge install smartcontractkit/chainlink-brownie-contracts
    ```
  - Specific version
    ```shell
    forge install smartcontractkit/chainlink-brownie-contracts@<version>
    ```
    - Example
      ```shell
      forge install smartcontractkit/chainlink-brownie-contracts@1.1.1
      ```
- [foundry-devops](https://github.com/Cyfrin/foundry-devops?tab=readme-ov-file#foundry-devops)
  - A repo to get the most recent deployment from a given environment in foundry. This way, you can do scripting off previous deployments in solidity.
    ```bash
    forge install Cyfrin/foundry-devops
    ```
