## Create Chimera App

This Foundry template allows you to bootstrap a fuzz testing suite using a scaffolding provided by the [Recon](https://getrecon.xyz/) tool.

It extends the default Foundry template used when running `forge init` to include example property tests using assertion tests and boolean property tests supported by [Echidna](https://github.com/crytic/echidna) and [Medusa](https://github.com/crytic/medusa).

Broken properties can be turned into unit tests for easier debugging with Recon ([for Echidna](https://getrecon.xyz/tools/echidna)/[for Medusa](https://getrecon.xyz/tools/medusa)) and added to the `CryticToFoundry` contract.

## Usage
To initialize a new Foundry repo using this template run the following command in the terminal.

```shell
forge init --template https://github.com/nican0r/create-chimera-app
```

### Build

```shell
forge build
```

### Foundry Test

```shell
forge test
```

This will run all unit, fuzz and invariant tests in the `CounterTest` and `CryticToFoundry` contracts.

### Echidna Property Test

```shell
echidna . --contract CryticTester --config echidna.yaml
```
Assertion mode is enabled by default in the echidna.yaml config file meaning the fuzzer will check assertion and property tests. 

To test only in property mode enable `testMode: "property"` in [echidna.yaml](https://github.com/nican0r/create-chimera-app/blob/main/echidna.yaml).

### Medusa Property Test

```shell
medusa fuzz
```
Assertion mode is enabled by default in the medusa.json config file meaning the fuzzer will check assertion and property tests. 

To test only in property mode disable assertion mode using:

```json
"assertionTesting": {
    "enabled": true
}  
```

in [medusa.json](https://github.com/nican0r/create-chimera-app/blob/main/medusa.json).