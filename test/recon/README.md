# Recon Fuzzing Suite

This is an auto-generated fuzzing test suite created by [Recon](https://getrecon.xyz/).

## File Structure

```
recon/
├── Setup.sol              # Contract deployment and initialization
├── BeforeAfter.sol        # Ghost variables for state tracking
├── SelectorStorage.sol    # Function selector constants
├── Properties.sol         # YOUR INVARIANTS GO HERE
├── TargetFunctions.sol    # Non-separated target functions
├── CryticTester.sol      # Entry point for Echidna/Medusa
├── CryticToFoundry.sol   # Foundry test wrapper
├── helpers/
│   └── Utils.sol
├── managers/
│   ├── ActorManager.sol
│   └── AssetManager.sol
└── targets/
    ├── AdminTargets.sol
    └── *Targets.sol       # Per-contract targets
```

## Key Concepts

### Inheritance Chain

```
Setup (deploys contracts)
  └── BeforeAfter (ghost variables, trackOp)
        └── Properties (YOUR invariants)
              └── *Targets (function wrappers)
                    └── TargetFunctions
                          └── CryticTester
```

### Operation Tracking

Each target function uses `trackOp(selector)` which:
1. Sets `currentOperation` to the function's selector
2. Calls `__before()` to capture pre-state
3. Executes the function
4. Calls `__after()` to capture post-state

Example property using operation tracking:

```solidity
function property_deposit_increases_balance() public {
    if (currentOperation == SelectorStorage.VAULT_DEPOSIT) {
        gte(_after.vaultBalance, _before.vaultBalance, "deposit should increase balance");
    }
}
```

### Ghost Variables

In `BeforeAfter.sol`, the `Vars` struct captures state:

```solidity
struct Vars {
    uint256 vaultTotalAssets;
    uint256 userBalance;
}

function __before() internal {
    _before.vaultTotalAssets = vault.totalAssets();
    _before.userBalance = token.balanceOf(actor);
}

function __after() internal {
    _after.vaultTotalAssets = vault.totalAssets();
    _after.userBalance = token.balanceOf(actor);
}
```

### SelectorStorage

Contains named constants for function selectors:

```solidity
bytes4 constant VAULT_DEPOSIT = bytes4(keccak256("deposit(uint256)"));
bytes4 constant VAULT_WITHDRAW_0 = bytes4(keccak256("withdraw(uint256)"));
bytes4 constant VAULT_WITHDRAW_1 = bytes4(keccak256("withdraw(uint256,address)"));
```

Overloaded functions get _0, _1 suffixes.

## Files to Edit

| File | Purpose |
|------|---------|
| `Setup.sol` | Deploy contracts, set initial state, configure actors |
| `BeforeAfter.sol` | Add variables to `Vars` struct, implement `__before()`/`__after()` |
| `Properties.sol` | Write invariant functions (prefix with `property_`) |

## Auto-Generated Files (Don't Edit Below Marker)

- `SelectorStorage.sol` - Regenerated from ABIs
- `*Targets.sol` - Code below `/// AUTO GENERATED TARGET FUNCTIONS` marker is regenerated

## Writing Properties

```solidity
// Global invariant - checked after every operation
function property_solvent() public {
    gte(vault.totalAssets(), vault.totalSupply(), "insolvent");
}

// Operation-specific invariant
function property_withdraw_decreases_shares() public {
    if (currentOperation == SelectorStorage.VAULT_WITHDRAW_0) {
        lt(_after.userShares, _before.userShares, "shares should decrease");
    }
}
```

### Assertion Helpers

- `t(bool, string)` - assert true
- `eq(a, b, string)` - equal
- `gt(a, b, string)` - greater than
- `gte(a, b, string)` - greater or equal
- `lt(a, b, string)` - less than
- `lte(a, b, string)` - less or equal

## Running Fuzzers

```bash
# Echidna
echidna . --contract CryticTester --config echidna.yaml

# Medusa
medusa fuzz --config medusa.json

# Halmos
halmos --config halmos.toml
```

## Regenerating

After contract changes:
```bash
recon-generate --force
```

This preserves Setup.sol, BeforeAfter.sol, Properties.sol, and config files.
