## Create Chimera App


- [Usage](#usage)
- [Build](#build)
- [Foundry Testing](#foundry-testing)
- [Echidna Property Testing](#echidna-property-testing)
- [Medusa Property Testing](#medusa-property-testing)
- [Uploading Fuzz Job To Recon](#uploading-fuzz-job-to-recon)
- [On-Chain Fuzzing with Echidna and Chimera](#on-chain-fuzzing-with-echidna-and-chimera)


This Foundry template allows you to bootstrap a fuzz testing suite using a scaffolding provided by the [Recon](https://getrecon.xyz/tools/sandbox) tool.

It extends the default Foundry template used when running `forge init` to include example property tests using assertion tests and boolean property tests supported by [Echidna](https://github.com/crytic/echidna) and [Medusa](https://github.com/crytic/medusa).

Broken properties can be turned into unit tests for easier debugging with Recon ([for Echidna](https://getrecon.xyz/tools/echidna)/[for Medusa](https://getrecon.xyz/tools/medusa)) and added to the `CryticToFoundry` contract.

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

### Echidna Property Testing

```shell
echidna . --contract CryticTester --config echidna.yaml
```
Assertion mode is enabled by default in the echidna.yaml config file.

To test in property mode enable `testMode: "property"` in [echidna.yaml](https://github.com/Recon-Fuzz/create-chimera-app/blob/main/echidna.yaml)).

### Medusa Property Testing

```shell
medusa fuzz
```
Assertion and property mode are enabled by default in the medusa.json config file meaning the fuzzer will check assertion and property tests. 

To test only in property mode disable assertion mode using:

```json
"assertionTesting": {
    "enabled": false
}  
```

in [medusa.json](https://github.com/Recon-Fuzz/create-chimera-app/blob/main/medusa.json).

## Expanding Target Functions

Once you wrote your Smart Contract, you can grab it's ABI and paste it here in Recon's Sandbox: https://getrecon.xyz/tools/sandbox

This will generate a new `TargetFunctions` file with all the updated handlers

You can combine multiple Target Function files to target different contracts and quickly reach coverage

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

# On-Chain Fuzzing with Echidna and Chimera

## Introduction

In this tutorial, you will learn how to start fuzzing on-chain targets very fast using Chimera and Echidna. Foundry is needed to generate the create-chimera-app template, to bootstrap a fuzz testing suite very fast.

## Step-by-Step Guide

### 1. Create Foundry Project with Chimera Template
```bash
forge init --template https://github.com/Recon-Fuzz/create-chimera-app onchain_fuzz
```

### 2. Generate Target Contract Interface
For example, generating UniswapV2Router interface:
```bash
cast interface 0xf164fC0Ec4E93095b804a4795bBe1e041497b92a -o src/ITarget.sol -c 1 -e {ETHERSCAN_API_KEY}
```
Notes:
- `-c 1` represents mainnet chain ID
- `-e` requires Etherscan API key (signup at Etherscan)
- Alternative: Manually create interface if preferred

### 3. Modify Interface and Setup
#### Update ITarget.sol
```diff
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

-interface UniswapV2Router01 {
+interface ITarget {
    receive() external payable;
    // ... rest of the interface
}
```

#### Update Setup.sol
```diff
// SPDX-License-Identifier: GPL-2.0
pragma solidity ^0.8.0;

import {BaseSetup} from "@chimera/BaseSetup.sol";
-import "src/Counter.sol";
+import "src/ITarget.sol";

abstract contract Setup is BaseSetup {
-    Counter counter;
+    ITarget target;

    function setup() internal virtual override {
-        counter = new Counter();
+        target = ITarget(payable(0xf164fC0Ec4E93095b804a4795bBe1e041497b92a));
    }
}
```

### 4. Update Echidna Configuration
Modify `echidna.yaml` to add RPC URL and optional block:
```yaml
rpcUrl: https://rpc.ankr.com/eth
rpcBlock: 21780400  # Optional: specific block for forking
```

### 5. Generate Target Functions
1. Retrieve contract ABI from explorer
2. Use [Recon Sandbox](https://getrecon.xyz/tools/sandbox) to generate targetfunctions
3. Copy generated functions to `TargetFunctions.sol` (**remove the existing functions**)

### 6. Project Clean-up
- In `Properties.sol`: Delete existing functions
- In `CryticToFoundry.sol`: Change `targetContract(address(counter))` to `targetContract(address(target))`
- In `BeforeAfter.sol`: Clear body of `__before()` and `__after()` functions

### 7. Run Echidna Fuzzing
```bash
echidna . --contract CryticTester --config echidna.yaml
```

### 8. Advanced Testing (Optional)
Expand your fuzzing capabilities:
- Introduce invariants/properties
- Add checks and actors
- Implement ghost variables
- Iterate to discover potential vulnerabilities
