# Diffusc: Differential Fuzzing of Upgradeable Smart Contract Implementations

This project has two parts so far:

1. [A POC for differential fuzzing on the Compound Comptroller](contracts/test/compound/Comptroller-diff.sol), in order to trigger the [COMP token distribution bug](https://twitter.com/Mudit__Gupta/status/1443454940165263360) introduced in an upgrade following [governance proposal 62](https://compound.finance/governance/proposals/62) in September 2021. This fuzz testing contract was manually written and requires setup (see below). The `build.sh` script deploys the entire Compound protocol twice using a fork of Compound's `compound-eureka` repo, saves the deployment transaction sequence to `echidna-init.json`, and stores the necessary addresses to `contracts/test/addresses.sol`.
    - A lot of this part (including most of this readme) is from the [solidity-fuzzing-boilerplate](https://github.com/patrickd-/solidity-fuzzing-boilerplate) template by [@patrickd](https://github.com/patrickd-).

2. `diffusc`, a tool for automatically generating differential fuzz testing contracts for comparing upgradeable smart contract implementations. The goal is to generalize the approach to detect unexpected discrepancies between any two implementation contracts, so as to prevent the introduction of bugs and vulnerabilities during a smart contract upgrade. The tool has two modes, basic '`path mode`' and '`fork mode`', with the mode used depending on how the input smart contracts are provided via the command line. 
    - `Path mode` works with file paths, and (optionally) deploys all target contracts in the test contract's constructor, though it may be necessary to add additional custom initialization logic by modifying the auto-generated code or using inheritance/overriding functions. 
    
    - `Fork mode` works with addresses of contracts that have already been deployed to a network, and requires an RPC endpoint URL to create two forks of the network. This requires less custom initialization, though it is slower due to the need for RPC queries and may be less flexible than custom initialization in some cases.


```
echidna.yaml           # Configuration file for Echidna.
foundry.toml           # Configuration file for Foundry.
build.sh               # Buildscript for downloading, compiling, initializing, ...
contracts
├── implementation     # Implementations to fuzz.
|   ├── compound       # Various versions of the Compound protocol.
|   |   ├── simplified-compound     # Compound with reduced functionality.
|   |   ├── compound-0.8.10         # V1/V2 contracts, updated to Solidity 0.8.10.
|   |   ├── Comptroller-before      # Original V1 contracts, using Solidity 0.5.16.
|   |   └── Comptroller-after       # Original V2 contracts, using Solidity 0.5.16.
|   ├── @openzeppelin  # OpenZeppelin contracts used by Compound POC test contracts.
│   └── ...
└── test               # Actual fuzzing testcases.
    ├── compound
    |   ├── ...
    |   ├── Compt-diff.sol          # POC to trigger Compound token distribution bug (part 1).
    |   ├── Comp-diff-fork.sol      # Modified POC to test in Echidna's experimental fork mode.
    |   ├── DiffFuzzUpgrades.sol    # Auto-generated test contract for Compound (part 2).
    |   ├── DiffFuzzModified.sol    # Manually fixed version of DiffFuzzUpgrades.sol.
    |   ├── DiffFuzzCustomInit.sol  # Inherits auto-generated contract and overrides functions.
    |   └── CryticConfig.yaml       # Auto-generated Echidna config file
    ├── ...
    ├── addresses.sol  # Addresses of incompatible libs, generated by buildscript.
    └── helpers.sol    # Reusable helper functions for tests.
src
├── diffusc.py       # Main module for diffusc tool (part 2).
└── diffusc
    ├── core
    |   ├── analysis_mode.py           # Base class for fork-mode and path-mode modules.
    |   ├── code_generation.py         # Code generation module.
    |   ├── fork_mode.py               # Main fork-mode module.
    |   └── path_mode.py               # Main path-mode module
    └── utils
        ├── classes.py                 # Helper classes.
        ├── crytic_print.py            # Printing to console
        ├── from_address.py            # Address-related utilities
        ├── from_path.py               # Path-related utilities
        ├── helpers.py                 # General-purpose helper functions
        ├── network_info_provider.py   # Class for getting data from the network
        ├── network_vars.py            # Lists and dicts of supported networks and env variables
        └── slither_provider.py        # Classes for getting Slither objects
```

## Part 1: Compound PoC
### Setup

Before any fuzzing can be run, `build.sh` needs to be executed, which has the following dependencies:

- bash
- curl
- [etheno](https://github.com/crytic/etheno)
- [foundry](https://book.getfoundry.sh/getting-started/installation.html)

After the buildscript was successfully executed, the addresses.sol contract should be populated, there'll be a `echidna-init.json` file and a ganache instance will still be running in the background.


```bash
# Differential fuzzing with protocol deployment via initialization file:
echidna --contract ComptrollerDiffFuzz --config echidna.yaml contracts/test/compound/Comp-diff.sol
```

### Running Echidna Fuzzing

## Part 2: Diffusc
Diffusc is a Python tool that uses static analysis to automatically generate differential fuzz testing invariants in Solidity for comparing two upgradeable smart contract implementations, which can uncover unexpected differences in behavior before an upgrade is performed on-chain. It also works just as well on two versions of a non-upgradeable contract.

Diffusc currently supports two modes: local mode and fork mode. Local mode, or path mode, takes file paths as inputs, whereas fork mode works with addresses of deployed contracts.
In local mode, the contracts under test will be deployed by the test contract's constructor, and some manual effort is likely to be necessary for initializing the contracts correctly.
Fork mode, on the other hand, inherits the on-chain state of the contracts under test, so less custom initialization is required. However, this mode requires an RPC node URL, and can be slower than local mode due to RPC queries.

### Setup

After cloning this repo, run the setup script (ideally in a virtual environment):
```bash
git clone https://github.com/webthethird/solidity-diff-fuzz-upgrades.git
cd solidity-diff-fuzz-upgrades
python3 setup.py install
```
You will also need to install [Echidna >=2.1.1](https://github.com/crytic/echidna/releases/tag/v2.1.1) in order to fuzz with te auto-generated test contracts.

### Running Diffusc
The minimum required arguments for running Diffusc are two contracts, provided as either file paths or addresses:

`diffusc v1 v2 [ADDITIONAL_ARGS]`
```bash
diffusc contracts/implementation/compound/compound-0.8.10/ComptrollerV1.sol contracts/implementation/compound/compound-0.8.10/ComptrollerV2.sol
echidna DiffFuzzUpgrades.sol --contract DiffFuzzUpgrades --config CryticConfig.yaml
```

#### Command Line Arguments
Additional options unlock greater functionality:
* `-p, --proxy`: Specifies the proxy to use (either a file path or an address, same mode as V1/V2).
* `-T, --targets`: Comma separated list of additional target contracts (either file paths or addresses, same as V1/V2).
* `-d, --output-dir`: Directory to store the test contract and config file in.
* `-A, --contract-addr`: Address to which to deploy the test contract.
* `-l, --seq-len`: Transaction sequence length for Echidna fuzzing (default 100).
* `-n, --network`: The network the contracts are deployed on (for fork mode). This parameter should have the same name as Slither supported networks. The current list of supported network prefixes is:
  * `mainet` for Ethereum main network (default if no `--network` is specified)
  * `optim` for Optimism
  * `bsc` for Binance Smart Chain
  * `arbi` for Arbitrum
  * `poly` for Polygon
  * `avax` for Avalanche
  * `ftm` for Fantom
  
  Also, the following test networks are supported:
  * `ropsten` for Ropsten (deprecated)
  * `kovan` for Kovan (deprecated)
  * `rinkeby` for Rinkeby (deprecated)
  * `goerli` for Goerli
  * `testnet.bsc` for Binance Smart Chain
  * `testnet.arbi` for Arbitrum
  * `mumbai` for Polygon
  * `testnet.avax` for Avalanche
  * `tobalaba` for Energy Web
* `-b, --block`: The block to use (for fork mode). Can also be set using the `ECHIDNA_RPC_BLOCK` environment variable.
* `-R, --network-rpc`: The RPC node URL to use (for fork mode). Can also be set using the `ECHIDNA_RPC_URL` environment variable.
* `--etherscan-key`: The block explorer API key to use (for fork mode). Can also be set using the `ETHERSCAN_API_KEY` environment variable.
* `-v, --version`: The solc compiler version to use (default 0.8.0).
* `-u, --fuzz-upgrade`: Flag to include an upgrade function in test contract, to upgrade to V2 mid-transaction sequence (default false).
* `--protected`: Flag to include test wrappers for protected functions, i.e., with modifier like `onlyOwner` (default false).

##### ✂ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - SNIP - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Solidity Fuzzing Boilerplate

This is a template repository intended to ease fuzzing components of Solidity projects, especially libraries.

- Write tests once and run them with both [Echidna](https://github.com/crytic/echidna) and [Foundry](https://book.getfoundry.sh/forge/fuzz-testing.html)'s fuzzing.
- Fuzz components that use incompatible Solidity versions by deploying those into a Ganache instance via Etheno.
- Use HEVM's FFI cheatcode to generate complex fuzzing inputs or to compare outputs with non-EVM executables while doing differential fuzzing.
- Publish your fuzzing experiments without worrying about licensing by extending the shellscript to download specific files.

## How to use the Template

### 1. Check & adjust configs

Check the [echidna.yaml](echidna.yaml) and [foundry.toml](foundry.toml) configuration files.

- Turn off FFI if you don't intend to make use of shell commands from your Solidity contracts. Note that FFI is slow and should only be used as a workaround. It can be useful for testing against things that are difficult to implement within Solidity and already exist in other languages. But it can also be dangerous: Before executing tests of a project that has FFI enabled, be sure to check what commands are actually being executed. There's nothing stopping someone to write a malicious testcase and execute malware on your computer.
- Adjust the compiler optimization options to match those of the project you're fuzzing.
- The default number of test runs configured, assumes that you intend to leave these tests running for a while to find edge cases, eg. on servers. Reduce the numbers accordingly if you only want to run quick tests.
- Adjust things like sequence lengths when fuzzing contracts that have a state (where a previous transaction can impact the next one).

### 2. Adjust Buildscript

Edit the [build.sh](build.sh) file and adjust it for your usecase

- Fetch the implementations that you want to apply fuzzing on.
- During RECORDing, deploy contracts of incompatible Solidity versions in order to access them during tests.
- If you're not dealing with any contracts of incompatible versions, you can simply omit the RECORD and DEPLOY calls.

### 3. Create testcases and exposers/interfaces as needed

Take a look at the [example testcases](contracts/test/example) and write your own.

### 4. Adjust the README.md

Don't forget to document the intention, setup and commands for your fuzzing campaign.
