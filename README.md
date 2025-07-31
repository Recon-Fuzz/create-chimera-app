## Create Chimera App

We've synthesized everything you need for invariant testing (tutorials, best practices, videos, and an invariant testing bootcamp) using this template in the [Recon Book](https://book.getrecon.xyz/).

## Table of Contents

- [Prerequisites](#prerequisites)
- [How it Works](#how-it-works)
- [Example Projects](#example-projects)
- [Usage](#usage)
  - [Build](#build)
  - [Property Testing](#echidna-property-testing)
  - [Foundry Testing](#foundry-testing)
- [Expanding Target Functions](#expanding-target-functions)
- [Uploading Fuzz Job To Recon](#uploading-fuzz-job-to-recon)
- [Credits](#credits)
- [Help](#help)

  
This Foundry template allows you to bootstrap an invariant fuzz testing suite using a scaffolding provided by the Recon [Handler Builder](https://getrecon.xyz/tools/builder) tool. You can generate a similar scaffolding for any existing project using the Handler Builder or the [Recon Extension](https://book.getrecon.xyz/free_recon_tools/recon_extension.html).

It extends the default Foundry template used when running `forge init` to include example property tests supported by [Echidna](https://github.com/crytic/echidna) and [Medusa](https://github.com/crytic/medusa).

## Prerequisites
To use this template you'll need to have Foundry and at least one fuzzer (Echidna or Medusa) or a symbolic testing tool (Halmos) installed:
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Echidna](https://github.com/crytic/echidna?tab=readme-ov-file#installation)
- [Medusa](https://github.com/crytic/medusa?tab=readme-ov-file#install)
- [Halmos](https://github.com/a16z/halmos?tab=readme-ov-file#installation)

## How it Works

For a full explainer of the different contracts that make up the Chimera Framework and are used in this template, checkout [this section](https://book.getrecon.xyz/writing_invariant_tests/chimera_framework.html) of the Recon Book.

For an in-depth explanation of the configuration options that come with this template and how to use it, see [this section](https://book.getrecon.xyz/writing_invariant_tests/create_chimera_app.html) of the Recon Book.

## Example Projects 
To see an end-to-end example of how to use this template to define properties on a contract and debug them when they break, checkout the [example project](https://book.getrecon.xyz/writing_invariant_tests/example_project.html) in the Recon Book. 

## Usage
To initialize a new Foundry repo using this template run the following command in the terminal.

```shell
forge init --template https://github.com/Recon-Fuzz/create-chimera-app
```

### Build
This template is configured to use Foundry as its build system for [Echidna](https://github.com/Recon-Fuzz/create-chimera-app-2/blob/271c3506a040b30011accfc15ba253cf99a4e6f1/echidna.yaml#L9) and [Medusa](https://github.com/Recon-Fuzz/create-chimera-app-2/blob/271c3506a040b30011accfc15ba253cf99a4e6f1/medusa.json#L73-L83) so after making any changes the project must successfully compile using the following command before running either fuzzer:

```shell
forge build
```

### Property Testing
This template comes with property tests defined for the `Counter` contract in the [`Properties`](https://github.com/Recon-Fuzz/create-chimera-app-2/blob/main/test/recon/Properties.sol) contract and in the function handlers in the [`TargetFunctions`](https://github.com/Recon-Fuzz/create-chimera-app-2/blob/14f651389623f23880723f01936c546b6d0234a1/test/recon/TargetFunctions.sol#L23-L51) contract.

See [this section](https://book.getrecon.xyz/writing_invariant_tests/implementing_properties.html) of the Recon Book to learn more about implementing properties.

#### Echidna Property Testing
To locally test properties using Echidna, run the following command in your terminal:
```shell
echidna . --contract CryticTester --config echidna.yaml
```

#### Medusa Property Testing
To locally test properties using Medusa, run the following command in your terminal:

```shell
medusa fuzz
```

### Foundry Testing
Broken properties found when running Echidna and/or Medusa can be turned into unit tests for easier debugging with Recon ([for Echidna](https://getrecon.xyz/tools/echidna)/[for Medusa](https://getrecon.xyz/tools/medusa)) and added to the `CryticToFoundry` contract (you can also do this directly in your editor using the [Recon VS Code extension](https://book.getrecon.xyz/free_recon_tools/recon_extension.html#reproducer-generation)).

```shell
forge test --match-contract CryticToFoundry -vv
```

You can then use optimization mode to increase the severity of findings as we've described [here](https://book.getrecon.xyz/writing_invariant_tests/optimizing_broken_properties.html).

#### Foundry Invariant Testing
To run invariant tests directly in Foundry using the built-in invariant testing framework, use the `invariants` profile:

```shell
FOUNDRY_PROFILE=invariants forge test --match-contract CryticToFoundry -vv
```

The number of test runs can be modified by the `runs` parameter in the `[profile.invariants.invariant]` section of `foundry.toml`.

### Halmos Invariant Testing
This template works out of the box for invariant testing with Halmos.

To run Halmos for invariant testing, run the `halmos` command in your terminal while in the root of this repository .

## Expanding Target Functions
After you've added new contracts in the `src` directory, they can then be deployed in the `Setup` contract.

The ABIs of these contracts can be taken from the `out` directory and added to Recon's [Handler Builder](https://book.getrecon.xyz/free_recon_tools/builder.html). The target functions that the builder generates can then be added to the existing `TargetFunctions` contract. 

## Uploading Fuzzing Job To Recon

You can offload your fuzzing job to Recon to run long duration jobs and share test results with collaborators using the [jobs page](https://book.getrecon.xyz/using_recon/running_jobs.html).

## Credits
This template implements the [`EnumerableSet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol) contract from OpenZeppelin and the [`ERC20`](https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol) contract from Solmate to reduce the number of dependencies and make it simpler to get started.

## Limitations

- Echidna `contractAddr` must be hardcoded due to how Echidna works
- Medusa uses `deployerAddress` to deploy libraries, burning nonces, as a sidestep we use a random `deployerAddress` and set `CryticTester` address in `predeployedContracts` 

## Help

If you need help using the template or have question about any of our tools, join the [Recon Discord](https://getrecon.xyz/discord).
