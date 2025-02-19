- [Prerequisites](#prerequisites)
- [Usage](#usage)
  - [Build](#build)
  - [Foundry Testing](#foundry-testing)
  - [Property Testing](#echidna-property-testing)
- [Uploading Fuzz Job To Recon](#uploading-fuzz-job-to-recon)
- [Credits](#credits)
  
## Create Chimera App
This Foundry template allows you to bootstrap an invariant fuzz testing suite using a scaffolding provided by the [Recon](https://getrecon.xyz/tools/sandbox) tool.

It extends the default Foundry template used when running `forge init` to include example property tests supported by [Echidna](https://github.com/crytic/echidna) and [Medusa](https://github.com/crytic/medusa).

Broken properties can be turned into unit tests for easier debugging with Recon ([for Echidna](https://getrecon.xyz/tools/echidna)/[for Medusa](https://getrecon.xyz/tools/medusa)) and added to the `CryticToFoundry` contract.

## Prerequisites
To use this template you'll need to have Foundry installed and at least one of the fuzzers (Echidna or Medusa):
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Echidna](https://github.com/crytic/echidna?tab=readme-ov-file#installation)
- [Medusa](https://github.com/crytic/medusa?tab=readme-ov-file#install)

## Usage
To initialize a new Foundry repo using this template run the following command in the terminal.

```shell
forge init --template https://github.com/Recon-Fuzz/create-chimera-app
```

### Build

```shell
forge build
```

### Foundry Testing

```shell
forge test
```

This will run all unit, fuzz and invariant tests in the `CounterTest` and `CryticToFoundry` contracts.

### Property Testing
This template comes with property tests defined for the `Counter` contract in the [`Properties`](https://github.com/Recon-Fuzz/create-chimera-app-2/blob/main/test/recon/Properties.sol) contract and in the function handlers in the [`TargetFunctions`](https://github.com/Recon-Fuzz/create-chimera-app-2/blob/14f651389623f23880723f01936c546b6d0234a1/test/recon/TargetFunctions.sol#L23-L51) contract.

#### Echidna Property Testing

```shell
echidna . --contract CryticTester --config echidna.yaml
```

#### Medusa Property Testing

```shell
medusa fuzz
```

## Expanding Target Functions
After you've added new contracts in the `src` directory, you can get their ABIs from the `out` directory and paste them in Recon's [Sandbox](https://getrecon.xyz/tools/sandbox).

These additional contracts can then be deployed in the `Setup` contract and you can add the target functions that the sandbox generated to the existing `TargetFunctions` contract. 

## Uploading Fuzz Job To Recon

You can offload your fuzzing job to Recon to run long duration jobs and share test results with collaborators using the [jobs page](https://getrecon.xyz/dashboard/jobs) on Recon:

#### Medusa
1. Select Medusa as the job type using the radio buttons at the top of the page.
2. Add the link for this repo in the *Enter GitHub Repo URL* form field (this will prefill the remaining form fields)
<div align="center">
    <img src="https://github.com/Recon-Fuzz/create-chimera-app/assets/94120714/9f9038f6-5f9f-4b0a-bdc0-ba6aedaaaded">
</div>    

2. Specify the `medusa.json` config file in the *Medusa config filename* field.
<div align="center">
  <img src="https://github.com/Recon-Fuzz/create-chimera-app/assets/94120714/5c2a2763-eff9-4ddf-aa1d-4835f93fc0f4">
</div>

3. Optional: to override the `timeout` value in the Medusa config file for longer duration runs enter a value (in seconds) into the *Test Time Limit* field.

### Echidna
1. Select Echidna as the job type using the radio buttons at the top of the page.
   
2. Add the link for this repo in the *Enter GitHub Repo URL* form field (this will prefill the remaining form fields)
<div align="center">
    <img src="https://github.com/Recon-Fuzz/create-chimera-app/assets/94120714/3f9a0dec-60e1-4be7-86bf-fa5d1945c228">
</div>    

3. Add the following path to the test contract, config filename and test contract name to the corresponding form fields. Optional: to override the `timeout` and `testLimit` from the config file use the corresponding form fields.
<div align="center">
    <img src="https://github.com/Recon-Fuzz/create-chimera-app/assets/94120714/6f16e1ce-d753-4390-be3f-a60b40796a25">
</div> 

***

4. Clicking the *Run Job* button will upload the job to Recon's cloud fuzz runner service. You'll see info about your job in the *Job Details* section and you'll be able to view your job in the *All Jobs* section.
<div align="center">
    <img src="https://github.com/Recon-Fuzz/create-chimera-app/assets/94120714/af3420bb-1dab-4be1-bcec-de429a729afe">
</div> 


5. Clicking *View Details* button for a job lets you see the fuzzer logs and coverage report (only generated after the run is complete). You can share a fuzz run with any collaborators using the *Share Job Results* button.
<div align="center">
    <img src="https://github.com/Recon-Fuzz/create-chimera-app/assets/94120714/dd49627a-5875-4ed2-a59c-c02976a4562a">
</div>

## Credits
This template implements the [`EnumerableSet`](https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/structs/EnumerableSet.sol) contract from OpenZeppelin and the [`ERC20`](https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol) contract from Solmate to reduce the number of dependencies and make it simpler to get started.

