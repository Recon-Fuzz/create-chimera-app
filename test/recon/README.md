# Chimera Fuzzing Suite

Invariant testing suite built with the [Chimera](https://github.com/Recon-Fuzz/chimera) framework. Supports [Echidna](https://github.com/crytic/echidna), [Medusa](https://github.com/crytic/medusa), [Halmos](https://github.com/a16z/halmos), and [Foundry](https://book.getfoundry.sh/).

For a full walkthrough, see the [Recon Book](https://book.getrecon.xyz/).

## Template Structure

```
recon/
├── Setup.sol              # Contract deployment and initialization
├── BeforeAfter.sol        # Ghost variables for state tracking (Vars struct)
├── Properties.sol         # Global invariant properties
├── TargetFunctions.sol    # Handler functions called by the fuzzer
├── CryticTester.sol       # Entry point for Echidna/Medusa
├── CryticToFoundry.sol    # Foundry wrapper for debugging failures
└── targets/
    ├── AdminTargets.sol       # Privileged handlers (asAdmin)
    ├── DoomsdayTargets.sol    # Stateless property checks
    └── ManagersTargets.sol    # Actor/asset management handlers
```


### Contract Roles

**Setup.sol** — Deploy and initialize all target contracts. Includes `ActorManager` and `AssetManager` for multi-actor/multi-token testing, and defines the `asActor`/`asAdmin` modifiers.

**BeforeAfter.sol** — Defines the `Vars` struct to snapshot state before and after handler calls. Provides `__before()`/`__after()` functions and the `updateGhosts` modifier.

**Properties.sol** — Global invariants that are checked after every handler call. These should only read state and make assertions, never change state.

**TargetFunctions.sol** — The handlers the fuzzer will call. These are the **only** functions the fuzzer invokes. Each handler wraps a target contract call and can include input clamping and inlined assertions. See [Implementing Properties](https://book.getrecon.xyz/writing_invariant_tests/implementing_properties.html) for when to use global vs inlined properties.

**targets/AdminTargets.sol** — Handlers that execute as admin via the `asAdmin` modifier, for privileged operations.

**targets/DoomsdayTargets.sol** — Complex property checks that need state changes but revert afterward via the `stateless` modifier, so they have no side effects on the fuzzing campaign.

**targets/ManagersTargets.sol** — Handlers for switching actors (`switchActor`), switching assets (`switch_asset`), deploying new tokens (`add_new_asset`), and managing approvals/mints.

**CryticTester.sol** — Fuzzer entry point. Inherits all handlers and calls `setup()` in the constructor.

**CryticToFoundry.sol** — Reproduce failing call sequences from Echidna/Medusa as Foundry unit tests for debugging.

## Best Practices

- **One state change per handler** — keeps reproducer sequences easy to debug
- **Deploy all contracts in `Setup.sol`** — not in constructors or handlers
- **Global properties must not change state** — only read and assert in `Properties.sol`; use `DoomsdayTargets.sol` with `stateless` for properties that need state changes
- **Use Chimera assertions** (`t`, `eq`, `gt`, `gte`, `lt`, `lte`) — not Foundry's `assertEq`/`assertTrue`
- **Place `updateGhosts` before `asActor`/`asAdmin`** — modifier order matters to avoid consuming the prank
- **Keep `__before()`/`__after()` safe** — only read state, never put operations that can revert
- **Use try/catch for expected reverts** — filter known errors with `checkError()`, fail on unexpected ones
- **Provide clamped and unclamped handlers** — clamped version calls the unclamped one to avoid duplicating inlined assertions
- **Mock complex dependencies** — replace oracles or heavy periphery with mocks so the fuzzer explores target state space faster

For more, see [Advanced Fuzzing Tips](https://book.getrecon.xyz/writing_invariant_tests/advanced.html).

## Running

```bash
# Echidna
echidna . --contract CryticTester --config echidna.yaml

# Medusa
medusa fuzz

# Halmos
halmos --config halmos.toml

# Foundry — debug broken reproducers
forge test --match-contract CryticToFoundry -vv

# Foundry — run invariant tests
FOUNDRY_PROFILE=invariants forge test --match-contract CryticToFoundry -vv --show-progress
```
