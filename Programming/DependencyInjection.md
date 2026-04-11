---
title: Dependency Injection
layer: programming
type: concept
priority: high
version: 2.0.0
tags:
  - Programming
  - Architecture
  - Patterns
  - InversionOfControl
  - Testability
description: A design pattern where objects receive their dependencies from external sources rather than creating them internally, enabling loose coupling and testability.
---

# Dependency Injection

## Description

Dependency Injection (DI) is a concrete implementation of the Inversion of Control (IoC) principle where an object's collaborators (dependencies) are provided — "injected" — by an external entity rather than the object constructing them itself. This decouples the *use* of a dependency from its *construction*, making systems easier to test, refactor, and reconfigure.

There are three canonical injection forms:
- **Constructor injection** — dependencies are required parameters of the constructor. This is the default choice for mandatory dependencies.
- **Setter/property injection** — dependencies are assigned via setters or mutable properties after construction. Useful for optional dependencies.
- **Method/parameter injection** — dependencies are passed directly to a method call. Useful when the dependency varies per call (e.g., a `CancellationToken`).

DI is often orchestrated by a **container** (Spring, Guice, Dagger, Autofac, Microsoft.Extensions.DependencyInjection) that resolves the dependency graph at runtime or compile time. However, DI as a pattern is independent of any container — you can do it with plain factory functions or even manual `new` calls in a composition root.

## When to Use

- **Unit testing is a requirement.** You need to swap real services (HTTP clients, databases, message brokers) with mocks or fakes during tests. Constructor injection makes this trivial.
- **You have multiple implementations of an abstraction.** E.g., a `PaymentProcessor` interface with `StripePaymentProcessor` and `PayPalPaymentProcessor`, selected at runtime by configuration.
- **Your application has a non-trivial object graph.** A typical web service may have 50–200 collaborating objects. Manual wiring in a single composition root clarifies the graph; a container automates it.
- **You need to vary configuration between environments** (dev, staging, prod) without changing code. The container binds different concrete types per environment.
- **You are building a library or framework** where consumers must supply their own implementations of extensibility points (e.g., ASP.NET Core middleware pipeline).

## When NOT to Use

- **Simple scripts or utilities** with fewer than ~10 collaborating objects. Manual construction is clearer than a DI container.
- **When DI is used purely to enable mocking** rather than to express real architectural boundaries. If the only reason for an interface is to mock it in tests, consider whether the abstraction is justified independently (see [[InterfaceSegregationPrinciple]]).
- **In performance-critical hot paths** where the indirection of virtual dispatch or container resolution adds measurable latency. DI containers add startup cost (graph resolution) and per-call cost (proxy interception, scoped resolution).
- **When the team lacks experience with DI patterns.** Misuse leads to the Service Locator anti-pattern, hidden dependencies, and unmaintainable code.
- **For value objects or entities** that represent data rather than behavior. A `User` entity does not need its dependencies injected.
- **When you need fine-grained control over object lifecycle** that conflicts with container semantics. E.g., you need exactly one instance of a stateful connection per request, but the container's scoped lifetime does not map to your request boundary.

## Tradeoffs

| Dimension | With DI Container | Without DI (Manual Wiring) |
|-----------|-------------------|---------------------------|
| **Boilerplate** | Container auto-wires; less manual code | Explicit construction in composition root |
| **Compile-time safety** | Runtime errors if registrations missing (unless using compile-time DI like Dagger) | All wiring checked at compile time |
| **Startup performance** | Graph resolution can add 10–500ms depending on complexity | Near-zero; objects created as needed |
| **Debuggability** | Stack traces can be deep and obscure | Straightforward call chains |
| **Refactoring** | Renaming a class may break container conventions | IDE refactoring handles all usages |
| **Testability** | Easy to override registrations per test | Must manually construct test doubles |
| **Learning curve** | Team must understand container semantics (transient/scoped/singleton) | Minimal; standard object-oriented code |

## Alternatives

- **Service Locator** — a registry that objects query for dependencies. Simpler to set up but hides dependencies in the object's interface, making it harder to understand what an object needs. Widely considered an anti-pattern by [[MarkSeemann]] and others.
- **Factory pattern** — factory methods or classes encapsulate object creation. Useful when construction logic is complex but the dependency graph is small.
- **Direct instantiation** — for simple cases, just `new` the dependencies. No abstraction overhead, but tight coupling.
- **Dependency Injection by hand (Poor Man's DI)** — manually wire the entire graph in a composition root (`Program.cs`, `main()`). Gives you all the decoupling benefits of DI with zero container overhead and full compile-time safety.
- **Event-driven / message-passing** — components communicate via events or messages rather than direct references. Eliminates direct dependencies but adds eventual consistency complexity.

## Failure Modes

1. **Constructor over-injection (the "Constructor Smell")** → a constructor takes 8+ parameters, indicating the class has too many responsibilities → apply the Single Responsibility Principle and split the class. A constructor with >5 parameters is a strong code smell.

2. **Hidden dependencies via Service Locator** → a class calls `ServiceLocator.Get<IFoo>()` inside a method, making its actual requirements invisible from its public API → use constructor injection so all dependencies are declared up front. This also prevents `NullReferenceException` from unregistered services.

3. **Captive dependencies** → a singleton component holds a reference to a scoped or transient component, effectively promoting it to singleton lifetime and causing stale state → the container should validate lifestyle mismatches. In Autofac, enable `ValidateOnBuild`. In .NET, review the service registration graph.

4. **Scope leaks across requests** → a scoped dependency (e.g., a database context) is inadvertently held beyond a single request, causing stale data or connection exhaustion → ensure the DI scope is tied to the request lifecycle (e.g., `HttpContext.RequestServices` in ASP.NET Core).

5. **Circular dependencies** → `ServiceA` depends on `ServiceB`, which depends on `ServiceA`. The container throws at startup → break the cycle by introducing an event, a third mediator service, or lazy injection (`Lazy<T>` / `Provider<T>`).

6. **Compile-time DI code generation overhead** → Dagger (Java/Kotlin) or Micronaut generate massive amounts of code at compile time, increasing build times from seconds to minutes → use DI containers selectively for the core application graph; manually wire simple modules.

7. **Transient dependency disposal failures** → a transient service implementing `IDisposable` is resolved from the root scope and never disposed, leaking file handles or connections → either scope the service properly or avoid `IDisposable` on transient services. In .NET, the root provider does not dispose transient services.

8. **Over-reliance on container-specific attributes** → using `[Inject]`, `[Autowired]`, or `[FromServices]` ties your code to a specific container, making migration painful → prefer constructor injection, which is container-agnostic.

9. **Testing with the real container** → spinning up the full DI container in unit tests makes them slow and brittle → resolve the class under test manually in the test, providing mocks as constructor arguments. Reserve container integration tests for a separate test suite.

10. **Ambient context abuse** → using static singletons like `DateTime.Now` or `HttpContext.Current` instead of injecting an `IClock` or `IHttpContextAccessor` → inject abstractions for ambient state to enable deterministic testing.

## Code Examples

### Constructor Injection (Recommended Default)

```csharp
// Good: all dependencies explicit, class is self-documenting
public class OrderService
{
    private readonly IOrderRepository _repository;
    private readonly IPaymentGateway _paymentGateway;
    private readonly ILogger<OrderService> _logger;

    public OrderService(
        IOrderRepository repository,
        IPaymentGateway paymentGateway,
        ILogger<OrderService> logger)
    {
        _repository = repository ?? throw new ArgumentNullException(nameof(repository));
        _paymentGateway = paymentGateway ?? throw new ArgumentNullException(nameof(paymentGateway));
        _logger = logger ?? throw new ArgumentNullException(nameof(logger));
    }

    public async Task<OrderResult> ProcessOrderAsync(Order order, CancellationToken ct)
    {
        _logger.LogInformation("Processing order {OrderId}", order.Id);
        await _repository.SaveAsync(order, ct);
        return await _paymentGateway.ChargeAsync(order.Total, ct);
    }
}
```

### Composition Root (Poor Man's DI — No Container)

```csharp
// No DI container needed for moderate-sized applications
public static class CompositionRoot
{
    public static IHostApplicationBuilder ConfigureServices(IHostApplicationBuilder builder)
    {
        var config = builder.Configuration;

        // Core services
        builder.Services.AddSingleton<IClock, SystemClock>();
        builder.Services.AddScoped<IOrderRepository, OrderRepository>();
        builder.Services.AddScoped<IPaymentGateway, StripePaymentGateway>();

        // The framework itself uses constructor injection for controllers
        builder.Services.AddControllers();
        builder.Services.AddLogging();

        return builder;
    }
}
```

### Anti-Pattern: Service Locator

```csharp
// BAD: hidden dependencies, hard to test, runtime errors possible
public class BadOrderService
{
    public void ProcessOrder(Order order)
    {
        // Dependencies are invisible from the API
        var repo = ServiceLocator.Resolve<IOrderRepository>();
        var gateway = ServiceLocator.Resolve<IPaymentGateway>();

        repo.Save(order);
        gateway.Charge(order.Total);
    }
}

// GOOD: explicit dependencies via constructor
public class GoodOrderService
{
    private readonly IOrderRepository _repo;
    private readonly IPaymentGateway _gateway;

    public GoodOrderService(IOrderRepository repo, IPaymentGateway gateway)
    {
        _repo = repo;
        _gateway = gateway;
    }

    public void ProcessOrder(Order order)
    {
        _repo.Save(order);
        _gateway.Charge(order.Total);
    }
}
```

### Compile-Time DI with Dagger (Kotlin/Android)

```kotlin
// Module declares how to construct dependencies
@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext ctx: Context): AppDatabase =
        Room.databaseBuilder(ctx, AppDatabase::class.java, "app-db")
            .fallbackToDestructiveMigration()
            .build()

    @Provides
    fun provideOrderDao(db: AppDatabase): OrderDao = db.orderDao()
}

// Component generates the graph at compile time
@Singleton
@Component(modules = [AppModule::class])
interface AppComponent {
    fun inject(activity: MainActivity)
}
```

## Best Practices

- **Prefer constructor injection** for all mandatory dependencies. It makes the class's requirements explicit, enables immutability (`readonly` / `val`), and guarantees the object is fully initialized.
- **Use interfaces or protocols as dependency types**, not concrete classes. This enables substitution in tests and between environments.
- **Keep the composition root close to the application entry point** (`Program.cs`, `Application.kt`, `main.go`). This is the one place where you are allowed to know about concrete types.
- **Do not use the container as a service locator** inside your application code. If you need to resolve something, it should be a constructor parameter.
- **Choose lifetimes deliberately**: transient for stateless services, scoped for per-request/per-unit-of-work services, singleton for shared infrastructure (caches, configuration). Default to transient or scoped.
- **Validate the container on startup** (`.ValidateScopes()`, `.ValidateOnBuild()` in .NET; `component.verify()` in Guice). Catch registration errors before production.
- **Test classes by constructing them directly**, bypassing the container. Pass mocks or fakes as constructor arguments. This makes tests fast and focused.
- **Use the Mediator pattern** (e.g., MediatR) to reduce the number of injected dependencies in application services. A single `IMediator` dependency replaces 10+ service interfaces.
- **Avoid injecting containers or `IServiceProvider` directly** into your classes. This is the Service Locator anti-pattern in disguise.
- **Document your lifetime choices** in a central registration file so the team understands why each service is transient, scoped, or singleton.

## Related Topics

- [[InversionOfControl]]
- [[InterfaceSegregationPrinciple]]
- [[SingleResponsibilityPrinciple]]
- [[DependencyInversionPrinciple]]
- [[ServiceLocatorAntiPattern]]
- [[CompositionRoot]]
- [[FactoryPattern]]
- [[TestDoublePatterns]]
- [[Programming MOC]]
- [[Architecture MOC]]
- [[Design MOC]]
- [[Quality MOC]]
