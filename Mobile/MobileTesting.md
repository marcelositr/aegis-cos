---
title: Mobile Testing
title_pt: Testes Mobile
layer: testing
type: practice
priority: medium
version: 1.0.0
tags:
  - Testing
  - Mobile
  - iOS
  - Android
  - Automation
description: Testing strategies for mobile applications including unit, integration, and UI testing.
description_pt: Estratégias de teste para aplicativos mobile incluindo testes unitários, integração e UI.
prerequisites:
  - Testing
  - Mobile
estimated_read_time: 10 min
difficulty: intermediate
---

# Mobile Testing

## Description

Mobile testing ensures quality across different devices, OS versions, and screen sizes. It includes unit tests, integration tests, UI tests, and device-specific testing. Mobile testing faces unique challenges like device fragmentation, OS version differences, and hardware variations.



## Purpose

**When this is valuable:**
- For understanding and applying the concept
- For making architectural decisions
- For team communication

**When this may not be needed:**
- For quick reference
- For simple implementations
- When basics are well understood

**The key question:** How does this concept help us build better software?

## Examples

### iOS Testing (XCTest)

```swift
// Unit Test
import XCTest
@testable import MyApp

class UserServiceTests: XCTestCase {
    var userService: UserService!
    
    override func setUp() {
        super.setUp()
        userService = UserService()
    }
    
    func testFetchUsersSuccess() async throws {
        let users = try await userService.fetchUsers()
        XCTAssertFalse(users.isEmpty)
    }
}

// UI Test
class MyAppUITests: XCTestCase {
    func testLoginFlow() {
        let app = XCUIApplication()
        app.launch()
        
        app.textFields["username"].tap()
        app.textFields["username"].typeText("testuser")
        
        app.secureTextFields["password"].tap()
        app.secureTextFields["password"].typeText("password")
        
        app.buttons["Login"].tap()
        
        XCTAssert(app.staticTexts["Welcome"].exists)
    }
}
```

### Android Testing (JUnit, Espresso)

```kotlin
// Unit Test
class UserRepositoryTest {
    @Test
    fun testFetchUsers() = runTest {
        val repository = UserRepository(mockApi)
        val users = repository.getUsers()
        assertTrue(users.isNotEmpty())
    }
}

// UI Test (Espresso)
@Test
fun testLogin() {
    onView(withId(R.id.username)).perform(typeText("test"))
    onView(withId(R.id.password)).perform(typeText("pass"))
    onView(withId(R.id.login)).perform(click())
    onView(withId(R.id.welcome)).check(matches(isDisplayed()))
}
```

## Anti-Patterns

### 1. No Device Testing

```kotlin
// BAD - only testing on emulator
// GOOD - test on real devices
```

## Failure Modes

- **Testing only on emulators** → missing hardware-specific bugs → production crashes → test on real devices across manufacturers
- **No network condition testing** → app fails on slow/flaky networks → poor UX → test offline, 3G, and intermittent connectivity
- **Ignoring OS version fragmentation** → crashes on older versions → user complaints → test on minimum supported OS version and latest
- **No UI test automation** → manual regression testing → slow releases → automate UI tests with XCTest/Espresso in CI/CD
- **Not testing app lifecycle** → state loss on background/restore → data loss → test backgrounding, foregrounding, and process death
- **Missing permission testing** → denied permissions cause crashes → app failure → test all permission denial and grant scenarios
- **No performance testing** → janky UI → user abandonment → measure frame rates, memory usage, and launch times on real devices

## Related Topics

- [[iOSDevelopment]]
- [[AndroidDevelopment]]
- [[UnitTesting]]
- [[IntegrationTesting]]
- [[E2ETesting]]
- [[TestArchitecture]]
- [[CiCd]]
- [[MobileArchitecture]]

## Best Practices

1. **Test on real devices** - Emulators don't catch hardware issues
2. **Automate regression tests** - CI/CD integration
3. **Test on multiple OS versions** - Support range of versions
4. **Use device labs** - Firebase Test Lab, AWS Device Farm
5. **Test network conditions** - Offline, slow 3G, flaky networks