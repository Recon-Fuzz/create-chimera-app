## Create Chimera App


- [Usage](#usage)
- [Build](#build)
- [Foundry Testing](#foundry-testing)
- [Echidna Property Testing](#echidna-property-testing)
- [Medusa Property Testing](#medusa-property-testing)
- [Uploading Fuzz Job To Recon](#uploading-fuzz-job-to-recon)

This Foundry template allows you to bootstrap a fuzz testing suite using a scaffolding provided by the [Recon](https://getrecon.xyz/) tool.

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
  
