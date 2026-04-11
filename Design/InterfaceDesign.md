---
title: Interface Design
title_pt: Design de Interfaces
layer: design
type: concept
priority: high
version: 1.0.0
tags:
  - Design
  - InterfaceDesign
description: Principles for creating intuitive and consistent user interfaces.
description_pt: Princípios para criar interfaces de usuário intuitivas e consistentes.
prerequisites: []
estimated_read_time: 10 min
difficulty: intermediate
---

# Interface Design

## Description

Interface design (UI/UX) focuses on creating intuitive, efficient, and pleasant user interfaces. While this often refers to visual interfaces, the principles apply to any interface: APIs, CLIs, libraries, and even function signatures.

Good interface design reduces cognitive load, guides users toward their goals, and provides feedback on actions. It follows principles like consistency, feedback, affordances, and error prevention.

## Purpose

**When interface design matters:**
- Building user-facing applications
- Creating developer tools
- Designing APIs
- Creating CLIs
- Any system with human interaction

## Rules

1. **Be consistent** - Similar elements behave similarly
2. **Provide feedback** - Always show system status
3. **Use familiar patterns** - Don't reinvent the wheel
4. **Prevent errors** - Make it hard to do wrong things
5. **Be forgiving** - Allow undo operations
6. **Show context** - Help users understand where they are

## Examples

### Good CLI Interface

```python
# Good CLI: consistent, helpful
import click

@click.group()
def cli():
    """User management CLI."""
    pass

@cli.command()
@click.option('--name', required=True, help='User name')
@click.option('--email', required=True, help='User email')
def create(name, email):
    """Create a new user."""
    user = create_user(name, email)
    click.echo(f'Created user: {user.id}')

@cli.command()
def list():
    """List all users."""
    users = list_users()
    for user in users:
        click.echo(f'{user.id} - {user.name}')

# Consistent help text
# Consistent option patterns
# Clear command names
```

### Bad Interface Design

```python
# Bad: inconsistent, confusing
def do_stuff(a, b=None, c=False, d="", e=None, f=None):
    """Do stuff."""
    # What does this function do?
    # What do all these parameters mean?
    # What are valid values?
    # What does it return?
```

## Anti-Patterns

### 1. Leaky Abstractions

**Bad:** An interface that exposes internal implementation details like data structures, database queries, or protocol specifics
**Why it's bad:** Consumers become coupled to internals, making it impossible to change the implementation without breaking every consumer
**Good:** Design interfaces around what the consumer needs to do, not how the implementation works internally

### 2. Interface Bloat (Fat Interface)

**Bad:** Adding every conceivable method to an interface "just in case" someone needs it
**Why it's bad:** Violates Interface Segregation Principle — implementers are forced to provide methods they don't need, and consumers are confused about what to use
**Good:** Keep interfaces small and focused — split large interfaces into role-specific ones that consumers can compose

### 3. Boolean Parameter Proliferation

**Bad:** Methods with multiple boolean flags that change behavior (`process(data, true, false, true)`)
**Why it's bad:** Callers cannot understand what the flags mean without reading documentation, and adding a new flag requires changing all call sites
**Good:** Use separate methods with descriptive names (`processAndNotify()`, `processSilently()`) or a builder/configuration object

### 4. Inconsistent Error Signaling

**Bad:** Some interface methods return error codes, others throw exceptions, and others use sentinel values like `null` or `-1`
**Why it's bad:** Consumers cannot write uniform error handling — they must remember the error strategy for each method
**Good:** Establish a consistent error handling strategy across the entire interface — either exceptions, result types, or error codes, but not a mix

### 5. Breaking Changes Without Deprecation

**Bad:** Renaming a method, removing a parameter, or changing a return type without a deprecation period
**Why it's bad:** All consumers break simultaneously, creating coordination chaos and eroding trust in the interface
**Good:** Deprecate the old interface, provide the new one alongside it, and remove the old version after a reasonable migration period

## Best Practices

### 1. Clear Naming

```python
# Good: Descriptive names
def calculate_order_total(order: Order) -> Decimal:
    """Calculate total price for an order."""
    return sum(item.price * item.quantity for item in order.items)

# Bad: Vague names
def calc(o):
    """Calc stuff."""
    return sum(x.p * x.q for x in o.i)
```

### 2. Documentation

```python
def process_payment(
    amount: Decimal,
    currency: str,
    payment_method: str,
    customer_id: str
) -> PaymentResult:
    """
    Process a payment for an order.
    
    Args:
        amount: Amount to charge (in smallest currency unit)
        currency: ISO 4217 currency code (e.g., 'USD')
        payment_method: Payment method identifier
        customer_id: Customer identifier
    
    Returns:
        PaymentResult with status and transaction ID
    
    Raises:
        PaymentError: If payment processing fails
        ValidationError: If parameters are invalid
    
    Example:
        >>> result = process_payment(
        ...     amount=1999,
        ...     currency='USD',
        ...     payment_method='card_visa',
        ...     customer_id='cust_123'
        ... )
        >>> print(result.transaction_id)
        'txn_abc123'
    """
```

### 3. Error Messages

```python
# Good: Helpful error messages
class ValidationError(Exception):
    def __init__(self, field: str, message: str, value: Any):
        self.field = field
        self.value = value
        super().__init__(
            f"Validation failed for '{field}': {message}. "
            f"Got: {value!r}"
        )

# Usage
raise ValidationError(
    field='email',
    message='must be valid email address',
    value=user_input
)
```

### 4. Default Values

```python
# Sensible defaults
class UserService:
    def __init__(
        self,
        max_results: int = 100,  # Limit by default
        timeout: int = 30,        # Reasonable timeout
        retry_count: int = 3,     # Standard retry
        cache_ttl: int = 300     # 5 minute cache
    ):
        ...

# Good defaults prevent common errors
# Bad: max_results=None means no limit (dangerous!)
```

## Failure Modes

- **Breaking interface contracts** → changing method signatures or behavior → all consumers break simultaneously → version interfaces and maintain backward compatibility during transitions
- **Overly broad interfaces** → interface exposes too many methods → implementers forced to provide irrelevant functionality → apply Interface Segregation Principle with small focused interfaces
- **Inconsistent error handling across interface** → some methods throw, others return error codes → consumers cannot handle errors uniformly → establish consistent error handling patterns
- **Missing documentation for interface contracts** → implementers do not know preconditions or postconditions → incorrect implementations → document invariants, preconditions, and expected behavior
- **Leaking implementation details through interface** → interface reveals internal data structures → cannot change implementation without breaking → use abstract types and hide concrete implementations
- **Interface versioning without deprecation path** → breaking changes force immediate consumer migration → coordination overhead → deprecate old methods, add new ones, remove after grace period
- **Default parameter values hiding complexity** → methods with many optional parameters → unclear which combinations are valid → prefer method overloading or builder pattern for complex configuration

## Related Topics

- [[Design MOC]]
- [[APIDesign]]
- [[Abstraction]]
- [[Coupling]]
- [[Hexagonal]]

## Key Takeaways

- Interface design creates intuitive, consistent interaction surfaces for any human-facing system—UIs, APIs, CLIs, libraries, and function signatures
- Matters for user-facing applications, developer tools, APIs, CLIs, and any system with human interaction
- Tradeoff: intuitive interfaces reduce cognitive load and errors versus design effort and the discipline to resist feature creep
- Main failure mode: breaking interface contracts without deprecation paths causes all consumers to break simultaneously and erodes trust
- Best practice: use clear descriptive naming, document preconditions and postconditions, establish consistent error handling, provide sensible defaults, and apply Interface Segregation Principle
- Related: API design, abstraction, coupling, hexagonal architecture

## Additional Notes
