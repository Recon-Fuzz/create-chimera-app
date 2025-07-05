# Chimera Framework Project Structure

This is a **create-chimera-app** project using the Chimera framework for invariant testing with Echidna, Medusa, Foundry, Halmos and Kontrol.

## Prerequisites 

To make use of the fuzzing/formal verification tools that create-chimera-app supports, you'll need to install one of the following on your local machine: 
- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Echidna](https://github.com/crytic/echidna?tab=readme-ov-file#installation)
- [Medusa](https://github.com/crytic/medusa?tab=readme-ov-file#install)
- [Halmos](https://github.com/a16z/halmos?tab=readme-ov-file#installation)

## Project Layout
```
├── src/                    # Target contracts to test
│   └── Counter.sol         # Example contract
├── test/
│   ├── Counter.t.sol       # Traditional Foundry tests
│   └── recon/              # Chimera fuzzing framework
│       ├── Setup.sol       # Contract deployment & initialization
│       ├── TargetFunctions.sol  # Handler functions for fuzzing
│       ├── Properties.sol  # Invariant properties to test
│       ├── BeforeAfter.sol # State tracking (ghost variables)
│       ├── CryticTester.sol    # Fuzzer entry point
│       └── CryticToFoundry.sol # Debug failing tests
├── echidna.yaml           # Echidna fuzzer configuration
├── medusa.json            # Medusa fuzzer configuration
└── foundry.toml           # Foundry configuration
```

## Core Framework Contracts

### 1. Setup.sol
**Purpose**: Deploy and initialize target contracts
**Key Points**:
- Inherits from `BaseSetup`
- Contains all contract deployments in `setup()` function
- Called once before fuzzing begins
- Example: `counter = new Counter();`

### 2. TargetFunctions.sol  
**Purpose**: Define handler functions that fuzzers will call
**Key Points**:
- Inherits from `BaseTargetFunctions` and `Properties`
- Contains ONLY functions fuzzers should call
- Usually non-view/non-pure functions
- Can include input clamping and inline assertions
- Example: `function counter_increment() public { counter.increment(); }`

### 3. Properties.sol
**Purpose**: Define global invariant properties to test
**Key Points**:
- Inherits from `BeforeAfter` and `Asserts`
- Contains assertion-based invariants (preferred)
- Function names should start with `property_`
- Example: `function property_number_never_zero() public { t(counter.number() != 0, "number is 0"); }`

### 4. BeforeAfter.sol
**Purpose**: Track state changes using ghost variables
**Key Points**:
- Defines `Vars` struct for state tracking
- Provides `__before()` and `__after()` functions
- Used in properties to compare pre/post states
- Example: `_before.counter_number = counter.number();`

### 5. CryticTester.sol
**Purpose**: Fuzzer entry point
**Key Points**:
- Inherits from `TargetFunctions` and `CryticAsserts`
- Constructor calls `setup()`
- This is what fuzzers actually target
- Example: `contract CryticTester is TargetFunctions, CryticAsserts`

### 6. CryticToFoundry.sol
**Purpose**: Debug failing tests in Foundry
**Key Points**:
- Inherits from `Test`, `TargetFunctions`, `FoundryAsserts`
- Use to reproduce fuzzer failures
- Add failing sequences to `test_crytic()` function

## Assertion System

Use Chimera's assertion functions (NOT foundry's):
- `t(bool, string)` - assert true
- `eq(uint256, uint256, string)` - assert equal
- `gt(uint256, uint256, string)` - assert greater than
- `lt(uint256, uint256, string)` - assert less than
- `gte(uint256, uint256, string)` - assert greater than or equal
- `lte(uint256, uint256, string)` - assert less than or equal
- `between(value, low, high)` - clamp value between bounds
- `precondition(bool)` - set preconditions

## Running Tests

**Echidna**: `echidna . --contract CryticTester --config echidna.yaml`
**Medusa**: `medusa fuzz`
**Foundry**: `forge test --mc CryticToFoundry` (for testing reproducers)

## Key Principles

1. **Only functions in or inherited by TargetFunctions.sol get called by fuzzers**
2. **Deploy all contracts in Setup.sol, not in constructors**
3. **Use assertion mode (not property mode) for testing**
4. **Properties defined in `Properties.sol` not make state changes**
5. **Use ghost variables for complex state tracking**
6. **For complex properties that require making state changes to test for specific behavior, define them in `DoomsdayTargets.sol` and use the `stateless` modifier to revert their state changes after the function call**

## Configuration Files

### echidna.yaml
- **testMode**: Set to `"assertion"` for assertion-based testing
- **coverage**: Enables coverage-guided fuzzing
- **corpusDir**: Specifies the directory where the corpus from a fuzzing run will be stored
- **testLimit**: Number of transactions (override with `--test-limit`)
- **seqLen**: Max sequence length
- **shrinkLimit**: Attempts to minimize failing sequences

### medusa.json
- **assertion testing enabled**: Main testing mode
- **workers**: Parallel workers for fuzzing
- **callSequenceLength**: Max calls per sequence
- **coverageEnabled**: Save coverage-increasing sequences
- **targetContracts**: Specifies `CryticTester` as target
- **corpusDirectory**: Specifies the directory where the corpus from a fuzzing run will be stored

## When to Edit Each File

- **Add new target contract**: Update `Setup.sol`
- **Add new functions to test**: Update `TargetFunctions.sol`
- **Add new properties**: Update `Properties.sol` or `TargetFunctions.sol`, see [implementing-properties](#implementing-properties) for specifics
- **Track new state**: Update `BeforeAfter.sol`
- **Debug failing test**: Update `CryticToFoundry.sol`
- **Change fuzzer behavior**: Update config files

## Library Linking (if needed)

For libraries that include external functions, modify configs:

**Echidna**:
```yaml
cryticArgs: ["--compile-libraries=(LibraryName,0xaddress)", "--foundry-compile-all"]
deployContracts: [["0xaddress", "LibraryName"]]
```

**Medusa**:
```json
"compilation": {
  "platformConfig": {
    "args": ["--compile-libraries", "(LibraryName,0xaddress)", "--foundry-compile-all"]
  }
}
```

## Quick Reference - File Purposes

| File | Primary Use | Inherits From | Contains |
|------|-------------|---------------|----------|
| Setup.sol | Deploy contracts | BaseSetup | `setup()` function |
| TargetFunctions.sol | Handler functions | BaseTargetFunctions, Properties | Public functions for fuzzers |
| Properties.sol | Invariants | BeforeAfter, Asserts | `invariant_*()` functions |
| BeforeAfter.sol | State tracking | Setup | `Vars` struct, `__before()`, `__after()` |
| CryticTester.sol | Fuzzer entry | TargetFunctions, CryticAsserts | Constructor with `setup()` |
| CryticToFoundry.sol | Debugging | Test, TargetFunctions, FoundryAsserts | `test_*()` functions |

---

# Chimera Framework

The Chimera framework lets you run invariant tests with Echidna and Medusa that can be easily debugged using Foundry. 

The framework is made up of the following contracts:
- @test/recon/Setup.sol
- @test/recon/TargetFunctions
- @test/recon/Properties
- @test/recon/CryticToFoundry
- @test/recon/BeforeAfter
- @test/recon/CryticTester

These contracts are in this project by default and should not be deleted as their inheritance structure makes them interdependent. 

## The Contracts 

We'll now look at the role each of the above-mentioned contracts serve in building an extensible and maintainable fuzzing suite. 

### @test/recon/Setup.sol

This contract is used to deploy and initialize the state of your target contracts. It's called by the fuzzer before any of the target functions are called. 

Any contracts you want to track in your fuzzing suite should live here.

In our `create-chimera-app` template project, the `Setup` contract is used to deploy the `Counter` contract:
```solidity
abstract contract Setup is BaseSetup {
    Counter counter;

    function setup() internal virtual override {
        counter = new Counter();
    }
}
```

### @test/recon/TargetFunctions.sol

This is perhaps the most important file in your fuzzing suite, it defines the target function handlers that will be called by the fuzzer to manipulate the state of your target contracts. 

**Note: These are the _only_ functions that will be called by the fuzzer**. 

Because these functions have the aim of changing the state of the target contract, they usually only include non-view and non-pure functions. 

Target functions make calls to the target contracts deployed in the `Setup` contract. The handler that wraps the target function allows you to add clamping (reducing the possible fuzzed input values) before the call to the target contract and properties (assertions about the state of the target contract) after the call to the target contract. 

In our `create-chimera-app` template project, the `TargetFunctions` contract is used to define the `increment` and `setNumber` functions:

```solidity
abstract contract TargetFunctions is
    BaseTargetFunctions,
    Properties
{
    function counter_increment() public {
        counter.increment();
    }

    function counter_setNumber1(uint256 newNumber) public {
        // clamping can be added here before the call to the target contract
        // ex: newNumber = newNumber % 100;

        // example assertion test replicating testFuzz_SetNumber
        try counter.setNumber(newNumber) {
            if (newNumber != 0) {
                t(counter.number() == newNumber, "number != newNumber");
            }
        } catch {
            t(false, "setNumber reverts");
        }
    }

    function counter_setNumber2(uint256 newNumber) public {
        // same example assertion test as counter_setNumber1 using ghost variables
        __before();

        counter.setNumber(newNumber);

        __after();

        if (newNumber != 0) {
            t(_after.counter_number == newNumber, "number != newNumber");
        }
    }
}
```

### @test/recon/Properties.sol

This contract is used to define the properties that will be checked after the target functions are called. 

At Recon our preference is to define these as Echidna/Medusa assertion properties but they can also be defined as boolean properties.

In our `create-chimera-app` template project, the `Properties` contract is used to define a property that states that the number can never be 0:

```solidity
abstract contract Properties is BeforeAfter, Asserts {
    // example property test
    function invariant_number_never_zero() public {
        t(counter.number() != 0, "number is 0");
    }
}
```

### @test/recon/CryticToFoundry.sol

This contract is used to debug broken properties by converting the breaking call sequence from Echidna/Medusa into a Foundry unit test. When running jobs on Recon this is done automatically for all broken properties using the fuzzer logs. 

If you are running the fuzzers locally you can use the [Echidna](https://getrecon.xyz/tools/echidna) and [Medusa](https://getrecon.xyz/tools/medusa) tools on Recon to convert the breaking call sequence from the logs into a Foundry unit test. 

This contract is also useful for debugging issues related to the `setup` function and allows testing individual handlers in isolation to verify if they're working as expected for specific inputs.

In our `create-chimera-app` template project, the `CryticToFoundry` contract doesn't include any reproducer tests because all the properties pass. 

The `test_crytic` function demonstrates the template for adding a reproducer test:

```solidity
contract CryticToFoundry is Test, TargetFunctions, FoundryAsserts {
    function setUp() public {
        setup();

        targetContract(address(counter));
    }

    function test_crytic() public {
        // TODO: add failing property tests here for debugging
    }
}
```

### test/recon/BeforeAfter.sol

This contract is used to store the state of the target contract before and after the target functions are called in a `Vars` struct. 

These variables can be used in property definitions to check if function calls have modified the state of the target contract in an unexpected way.

In our `create-chimera-app` template project, the `BeforeAfter` contract is used to track the `counter_number` variable:

```solidity
// ghost variables for tracking state variable values before and after function calls
abstract contract BeforeAfter is Setup {
    struct Vars {
        uint256 counter_number;
    }

    Vars internal _before;
    Vars internal _after;

    function __before() internal {
        _before.counter_number = counter.number();
    }

    function __after() internal {
        _after.counter_number = counter.number();
    }
}
```

### @test/recon/CryticTester.sol

This is the entrypoint for the fuzzer into the suite. All target functions will be called on an instance of this contract since it inherits from the `TargetFunctions` contract.

In our `create-chimera-app` template project, the `CryticTester` contract is used to call the `counter_increment` and `counter_setNumber1` functions:

```solidity
// echidna . --contract CryticTester --config echidna.yaml
// medusa fuzz
contract CryticTester is TargetFunctions, CryticAsserts {
    constructor() payable {
        setup();
    }
}
```

### @lib/chimera/src/Asserts.sol

When using assertions from Chimera in your properties, they use a different interface than the standard assertions from foundry's `forge-std`.

The following assertions are available in Chimera's `Asserts` contract:

```solidity
abstract contract Asserts {
    // greater than
    function gt(uint256 a, uint256 b, string memory reason) internal virtual;

    // greater than or equal to
    function gte(uint256 a, uint256 b, string memory reason) internal virtual;

    // less than
    function lt(uint256 a, uint256 b, string memory reason) internal virtual;

    // less than or equal to
    function lte(uint256 a, uint256 b, string memory reason) internal virtual;

    // equal to
    function eq(uint256 a, uint256 b, string memory reason) internal virtual;

    // true
    function t(bool b, string memory reason) internal virtual;

    // between uint256
    function between(uint256 value, uint256 low, uint256 high) internal virtual returns (uint256);

    // between int256
    function between(int256 value, int256 low, int256 high) internal virtual returns (int256);

    // precondition
    function precondition(bool p) internal virtual;
}
```


# Implementing Properties

## Quick Decision Tree

**When implementing a property, ask:**
1. **What type?** → [Property Types](#property-types)
2. **Where to implement?** → [Implementation Location](#implementation-location)
3. **How to write?** → [Implementation Patterns](#implementation-patterns)

## Property Types

Choose the appropriate type based on what you're testing:

| Type | Purpose | Example |
|------|---------|---------|
| **Valid States** | System stays in expected states | `totalSupply >= sumOfBalances` |
| **State Transitions** | Valid state changes only | `balance only increases after mint/transfer` |
| **Variable Transitions** | Variables change as expected | `price per share doesn't increase on withdrawals` |
| **High-Level Properties** | Broad system behavior | `system remains solvent` |
| **Unit Tests** | Specific function behavior | `deposit never reverts with sufficient funds` |

## Implementation Location

### Use GLOBAL properties (in `Properties.sol`) when:
- ✅ Property should hold after **ANY** function call (true invariants)
- ✅ Checking system-wide state
- ✅ Property doesn't specify a particular operation

**Pattern:**
```solidity
/// @dev Property: [Clear description of what this checks]
function property_descriptive_name() public {
    // Read contract state
    // Make assertion using t(), eq(), lte(), etc.
}
```

### Use INLINED properties (in `TargetFunctions.sol`) when:
- ✅ Property only applies to **specific** function calls
- ✅ Need to check pre/post conditions of particular operations
- ✅ Property is operation-specific

**Pattern:**
```solidity
function targetContract_functionName(uint256 param) public {
    // Optional: Add preconditions/clamping
    
    // Call target function (with try/catch if needed)
    
    // Add property assertions specific to this function
}
```

## Implementation Patterns

### Pattern 1: Simple State Check (Global)
```solidity
/// @dev Property: Total supply must equal sum of all balances
function property_total_supply_conservation() public {
    uint256 totalSupply = token.totalSupply();
    uint256 sumBalances = _calculateSumOfBalances();
    eq(totalSupply, sumBalances, "totalSupply != sum of balances");
}
```

### Pattern 2: Before/After Comparison (Inlined)
```solidity
function vault_withdraw(uint256 assets) public {
    __before();
    vault.withdraw(assets, _getActor(), _getActor());
    __after();
    
    // Property: Price per share shouldn't increase
    lte(_after.pricePerShare, _before.pricePerShare, "price per share increased");
}
```

### Pattern 3: Try/Catch with Expected Errors (Inlined)
```solidity
function vault_deposit(uint256 assets) public {
    try vault.deposit(assets, _getActor()) {
        // Success - add any success-specific properties
    } catch (bytes memory reason) {
        bool expectedError = 
            checkError(reason, "InsufficientBalance") || 
            checkError(reason, "InsufficientAllowance");
        
        if (!expectedError) {
            t(false, "deposit should not revert for unexpected reason");
        }
    }
}
```

### Pattern 4: Conditional Properties (Global)
```solidity
function property_conditional_check() public {
    // Only check this property under certain conditions
    if (someCondition) {
        t(someAssertion, "condition-specific property failed");
    }
}
```

## Ghost Variables (BeforeAfter.sol)

**When to use:** Properties need to compare state before/after operations

**Setup:**
1. Add variables to `Vars` struct in `BeforeAfter.sol`
2. Update `__before()` and `__after()` functions
3. Use `_before.variableName` and `_after.variableName` in properties

```solidity
// In BeforeAfter.sol
struct Vars {
    uint256 totalSupply;
    uint256 userBalance;
    uint256 pricePerShare;
}

function __before() internal {
    _before.totalSupply = token.totalSupply();
    _before.userBalance = token.balanceOf(_getActor());
}

function __after() internal {
    _after.totalSupply = token.totalSupply();
    _after.userBalance = token.balanceOf(_getActor());
}
```

## Assertion Functions Reference

Use these instead of Foundry's assertions:

| Function | Use Case | Example |
|----------|----------|---------|
| `t(bool, string)` | General true assertion | `t(value > 0, "value must be positive")` |
| `eq(a, b, string)` | Equality | `eq(actual, expected, "values don't match")` |
| `gt(a, b, string)` | Greater than | `gt(balance, 0, "balance must be positive")` |
| `gte(a, b, string)` | Greater than or equal | `gte(totalSupply, sumBalances, "supply >= balances")` |
| `lt(a, b, string)` | Less than | `lt(fee, maxFee, "fee too high")` |
| `lte(a, b, string)` | Less than or equal | `lte(used, capacity, "over capacity")` |
| `precondition(bool)` | Skip test if false | `precondition(balance > amount)` |

## Common Mistakes to Avoid

❌ **Don't:** Put state-changing operations in `Properties.sol` functions  
✅ **Do:** Only read state and make assertions in `Properties.sol`

❌ **Don't:** Use Foundry assertions (`assertEq`, `assertTrue`)  
✅ **Do:** Use Chimera assertions (`eq`, `t`)

❌ **Don't:** Implement same property in multiple handlers  
✅ **Do:** Use global properties for system-wide invariants

❌ **Don't:** Forget to handle expected reverts  
✅ **Do:** Use try/catch with proper error checking

## Step-by-Step Implementation

1. **Identify the property type** from the table above
2. **Choose implementation location** (global vs inlined)
3. **Add ghost variables** if needed for before/after comparison
4. **Write the property** using appropriate assertion pattern
5. **Add clear documentation** with `/// @dev Property:` comment
6. **Test locally** with small inputs first

## Example: Complete ERC20 Property

```solidity
// In Properties.sol (Global - applies after any operation)
/// @dev Property: Total supply must always equal sum of all user balances
function property_total_supply_conservation() public {
    uint256 totalSupply = token.totalSupply();
    address[] memory users = _getActors();
    
    uint256 sumBalances;
    for (uint256 i = 0; i < users.length; i++) {
        sumBalances += token.balanceOf(users[i]);
    }
    
    eq(totalSupply, sumBalances, "totalSupply != sum of balances");
}

// In TargetFunctions.sol (Inlined - specific to transfer)
/// @dev Property: Transfer should only succeed with sufficient balance
function token_transfer(address to, uint256 amount) public {
    address from = _getActor();
    uint256 balanceBefore = token.balanceOf(from);
    
    try token.transfer(to, amount) {
        // Success case - verify balance decreased
        t(token.balanceOf(from) == balanceBefore - amount, "balance not decreased correctly");
    } catch {
        // Revert case - should only happen with insufficient balance
        t(balanceBefore < amount, "transfer reverted with sufficient balance");
    }
}
```

# Advanced Fuzzing Tips

## Quick Navigation

Choose your task:
- **Creating Target Functions** → Handler patterns, clamping, disabling
- **Setting Up Test Suite** → Deployment, story management, state exploration
- **Tracking State Changes** → Before/after state tracking
- **Inlined Properties** → Function-specific assertions
- **Finding Precision Issues** → Division/precision loss detection

## Target Functions

### Basic Handler Pattern
```solidity
// Target contract
contract Counter {
    uint256 public number;
    function increment() public { number++; }
}

// Handler in TargetFunctions.sol
abstract contract TargetFunctions {
    function counter_increment() public asActor {
        counter.increment();
    }
}
```

### Actor Management

**Use `asActor` for general functions:**
```solidity
function counter_increment() public asActor {
    counter.increment();
}
```

**Use `asAdmin` for privileged functions:**
```solidity
function yield_resetYield() public asAdmin {
    yield.resetYield();
}
```

### Clamping Strategy

**Pattern: Always provide both clamped and unclamped versions**

```solidity
// ✅ Unclamped handler (explores full space)
function counter_setNumber(uint256 newNumber) public asActor {
    counter.setNumber(newNumber);
    
    // Inlined property check
    if (newNumber != 0) {
        t(counter.number() == newNumber, "number != newNumber");
    }
}

// ✅ Clamped handler (calls unclamped with restricted inputs)
function counter_setNumber_clamped(uint256 newNumber) public asActor {
    newNumber = between(newNumber, 1, type(uint256).max);
    counter_setNumber(newNumber); // Call unclamped version
}
```

### Disabling Functions

**When to disable:**
- Functions that don't explore interesting states
- Admin functions causing too many false positives
- Functions that always revert in your setup

**How to disable:**
```solidity
// Option 1: Comment out
// function problematic_function() public asActor {
//     target.problematicFunction();
// }

// Option 2: Use alwaysRevert modifier
function problematic_function() public alwaysRevert {
    target.problematicFunction();
}
```

## Setup Best Practices

### ✅ Do's

| Practice | Why | Example |
|----------|-----|---------|
| **Create own setup** | Avoid existing test biases | `setup() { counter = new Counter(); }` |
| **Keep story clean** | One operation per handler | Separate `deposit()` and `withdraw()` handlers |
| **Mock complex contracts** | Simplify fuzzing | Mock oracles instead of full implementation |
| **Add donation handlers** | Explore edge states | Direct token transfers to contracts |

### ❌ Don'ts

| Avoid | Why | Better Approach |
|-------|-----|----------------|
| **Reusing existing tests** | Inherits biases | Write minimal setup from scratch |
| **Multiple operations per handler** | Hard to debug | One state change per handler |
| **Complex periphery contracts** | Slows fuzzing | Mock or simplify |

### Story Management

**❌ Bad: Multiple operations make debugging hard**
```solidity
function vault_deposit_and_redeem(uint256 assets) public asActor {
    uint256 sharesReceived = vault.deposit(assets);
    vault.redeem(sharesReceived);
}
```

**✅ Good: Separate handlers for clear story**
```solidity
function vault_deposit(uint256 assets) public asActor {
    vault.deposit(assets, _getActor());
}

function vault_redeem(uint256 shares) public asActor {
    vault.redeem(shares, _getActor(), _getActor());
}
```

### Programmatic Deployment Pattern

**Static deployment (limited):**
```solidity
function setup() internal {
    token = new MockERC20("Test", "TEST", 18); // Fixed 18 decimals
}
```

**✅ Programmatic deployment (comprehensive):**
```solidity
// In TargetFunctions.sol
function deploy_new_token(uint8 decimals) public {
    decimals = uint8(between(decimals, 6, 24));
    _newAsset(decimals);
}

function switch_active_token(uint256 index) public {
    _switchAsset(index);
}

// Use current token in other handlers
function token_transfer(uint256 amount) public asActor {
    IERC20 currentToken = _getAsset();
    currentToken.transfer(_getActor(), amount);
}
```

## Ghost Variables

### Basic Setup Pattern

**1. Define variables in BeforeAfter.sol:**
```solidity
struct Vars {
    uint256 totalSupply;
    uint256 userBalance;
    uint256 pricePerShare;
}

Vars internal _before;
Vars internal _after;
```

**2. Update ghost variables:**
```solidity
function __before() internal {
    _before.totalSupply = token.totalSupply();
    _before.userBalance = token.balanceOf(_getActor());
}

function __after() internal {
    _after.totalSupply = token.totalSupply();
    _after.userBalance = token.balanceOf(_getActor());
}
```

**❌ Don't: use in inlined handlers because `_after()` is only called after handler execution completes**
```solidity
function token_transfer(uint256 amount) public updateGhosts asActor {
    token.transfer(_getActor(), amount);
    
    // Use ghost variables in properties
    eq(_before.totalSupply, _after.totalSupply, "totalSupply changed");
}
```

**✅ Do: Use in global properties:**
```solidity
    function property_number_never_zero() public {
        eq(_after.totalSupply, _before.totalSupply, "totalSupply shouldn't change");
    }
```

### ⚠️ Critical Ghost Variable Rules

| ❌ Never Do | ✅ Always Do |
|-------------|--------------|
| Put assertions in `__before()` or `__after()` | Only read state values |
| Complex computations that might revert | Simple state reads |
| Operations that can fail | Safe, guaranteed operations |

**❌ Bad: Can revert and break fuzzing**
```solidity
function __before() internal {
    // This can underflow and revert!
    _before.difference = _before.balance - token.balanceOf(user);
}
```

**✅ Good: Safe state reading**
```solidity
function __before() internal {
    _before.balance = token.balanceOf(user);
    _before.totalSupply = token.totalSupply();
}
```

### Operation Type Tracking

**Setup operation types:**
```solidity
enum OpType { GENERIC, ADD, REMOVE }
OpType internal currentOperation;

modifier updateGhostsWithType(OpType op) {
    currentOperation = op;
    __before();
    _;
    __after();
}
```

**Use in handlers:**
```solidity
function vault_deposit(uint256 assets) public updateGhostsWithType(OpType.ADD) asActor {
    vault.deposit(assets, _getActor());
}

function vault_withdraw(uint256 assets) public updateGhostsWithType(OpType.REMOVE) asActor {
    vault.withdraw(assets, _getActor(), _getActor());
}
```

**Use in properties:**
```solidity
function property_price_per_share_on_removal() public {
    if (currentOperation == OpType.REMOVE) {
        lte(_after.pricePerShare, _before.pricePerShare, "price increased on removal");
    }
}
```

## Inlined Properties

### Basic Pattern
```solidity
function counter_setNumber(uint256 newNumber) public updateGhosts asActor {
    try counter.setNumber(newNumber) {
        // Property: number should equal input if input != 0
        if (newNumber != 0) {
            t(counter.number() == newNumber, "number != newNumber");
        }
    } catch {
        // Handle expected reverts
        t(false, "setNumber should not revert");
    }
}
```

### ❌ Avoid Duplication

**Don't repeat same property in multiple handlers:**
```solidity
// ❌ Bad: Same property in multiple places
function deposit_handler1() public {
    // ... deposit logic ...
    t(vault.totalSupply() >= sumBalances, "invariant violated");
}

function deposit_handler2() public {
    // ... different deposit logic ...
    t(vault.totalSupply() >= sumBalances, "invariant violated"); // Duplicated!
}
```

**✅ Use global property instead with OpType as a precondition:**
```solidity
// In Properties.sol
function property_total_supply_invariant() public {
    if(currentOperation == DEPOSIT) {
        t(vault.totalSupply() >= sumBalances, "invariant violated");
    }
}
```

### Stateless Pattern

**For testing without permanent state changes:**
```solidity
modifier stateless() {
    _;
    revert("stateless"); // Revert after execution
}

function doomsday_complex_scenario() public stateless {
    // Perform multiple operations to test scenario
    vault.deposit(1000);
    vault.withdraw(500);
    
    // Test property
    t(someComplexProperty(), "property failed");
    
    // State reverts after this function
}
```

## Rounding Errors

### Detection Strategy

**1. Start with exact checks:**
```solidity
function vault_withdraw(uint256 assets) public {
    uint256 sharesBefore = vault.balanceOf(_getActor());
    uint256 expectedShares = vault.previewWithdraw(assets);
    
    vault.withdraw(assets, _getActor(), _getActor());
    
    uint256 sharesAfter = vault.balanceOf(_getActor());
    uint256 actualSharesBurned = sharesBefore - sharesAfter;
    
    // Exact check - will fail if rounding occurs
    eq(actualSharesBurned, expectedShares, "shares burned != expected");
}
```

**2. Allow fuzzer to find violations:**
```bash
echidna . --contract CryticTester --config echidna.yaml
```

**3. Create optimization test for worst case:**
```solidity
// For Echidna optimization mode
function echidna_maximize_rounding_error() public returns (int256) {
    // Return the rounding error amount
    return expectedShares > actualSharesBurned ? 
           expectedShares - actualSharesBurned : 
           actualSharesBurned - expectedShares;
}
```

### Precision Loss Patterns

**Common scenarios to test:**
- Division operations: `amount / rate`
- Percentage calculations: `(amount * fee) / 10000`
- Conversions between different decimal places
- Compound operations: multiple divisions in sequence

## Quick Reference

### Essential Modifiers
- `asActor` - Execute as random actor
- `asAdmin` - Execute as admin
- `updateGhosts` - Track before/after state
- `updateGhostsWithType(OpType)` - Track state with operation type
- `stateless` - Revert state after execution
- `alwaysRevert` - Disable handler

### Assertion Functions
- `t(bool, string)` - General assertion
- `eq(a, b, string)` - Equality check
- `lte/gte(a, b, string)` - Comparison checks
- `between(value, min, max)` - Clamp values

### File Structure
- `Setup.sol` - Contract deployment
- `TargetFunctions.sol` - Handler functions
- `Properties.sol` - Global invariants
- `BeforeAfter.sol` - Ghost variable tracking

This guide provides actionable patterns for implementing advanced fuzzing techniques in the Chimera framework.
