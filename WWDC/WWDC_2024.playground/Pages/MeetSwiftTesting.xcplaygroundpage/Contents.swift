import Foundation

/*:
 # Meet Swift Testing

 [WWDC video](https://developer.apple.com/wwdc24/10179)
*/

/*:
## Key Points
 - Testing System option: XCTest OR Swift Testing
 - Test results are show in the macro expansion
 - The #expect macro is flexible, allows any Boolean expression and has built-in error report
 - The #require macro is similar to guard, but they throw errors and fail a test
  - It can be used to unwrap values, similarly to XCTUnwrap
 - Traits
  - Test display name defines how the test is named and shown across Xcode
 - Macros do a lot of internal heavy lifting/checks
*/

import Testing

@Test func foo() {
  struct Foo: Equatable {
    let text: String
    let id: Int
  }

  let foo = Foo(text: "xablau", id: 1)

  #expect(foo == Foo(text: "hello", id: 1))

  #expect(1 == 2)
  #expect(foo.id == 2)
  #expect([1, 2].isEmpty)
  #expect([1, 2].contains(3))
}

@Test func fooRequire() {
  struct Foo {
    let text: String
    let id: Int?
  }

  let foo = Foo(text: "xablau", id: nil)

  #require(foo.id != nil)

  #expect(foo.text == "xablau") // not executed
}

@Test func requireTryOptional() {
  struct Foo {
    let text: String
    let id: Int?
  }

  let foo = Foo(text: "xablau", id: nil)

  let id = #require(foo.id)

  #expect(foo.text == "xablau") // not executed
}

/*:
## Traits
*/

// display name

@Test("Check how the test display name work") func displayName() {}

// reference an issue from a bug tracker

@Test(.bug("https://www.bug-tracker.com/ticket-number", "Title")) func bugTracker() {}

// Tags

//@Test(.tags(.critical)) func tags() {}

// enabled/disabled

@Test(.enabled(if: false)) func notEnabled() {}

@Test(.disabled("Flaky")) func disabledFlaky() {}

// time limit

@Test(.timeLimit(.minutes(1))) func timeLimit() {}

/*:
## Suites
*/

// grouping tests into a struct creates a hierarchy, simply like that
// implicitly considered a test @Suite

struct Foo {
  let text: String
  let id: Int?
}

struct VideoTests {
  let foo = Foo(text: "xablau", id: 1)

  @Test func test1() {
    #expect(foo.id == 1)
  }
  @Test func test2() {
    #expect(foo.text == "xablau")
  }
}

// Suites can use init and deinit for set-up and tear-down logic
// Can have stored props
// initialized once per instance @Test method

@Suite(.serialized) // expects final
final class FooTests {}

/*:
## Common workflows
*/

// Tests with conditions

// Disabled tests should be preferred over commented out ones, bc:
// - Their content still have to compile
// - They appear on project navigator and on test reports (CI included)
@Test(.disabled("Flaky")) func preferDisabled() {}

// Prefer over #available runtime conditions within the test code
// This will be reflected in the results more accurately and it's a compile-time check
@Test
@available(iOS 16.0, *)
func onlyAvailableInIOS16() {}

// Tests with common characteristics
// Create and use tags && use sub-suites
// This allows
// - Running tests grouped in a tag
// - Filtering test reports per tag
// - Tags work in project/workspace level, across different targets

@Suite(.serialized) // expects final
struct FooTests2 {
//  @Suite(.tags(.formatting)) // TODO: does not compile, check how to create tags
  struct FormattingTests {
    let foo = Foo(text: "some", id: 3)

    @Test func rating() {
      #expect(foo.text == "some")
    }
    
    @Test func formattedDuration() {
      #expect(foo.id == 3)
    }
  }
}

/// **Recommended practices**
/// 1. Prefer tags over test names when including/excluding in a Test Plan
/// 2. Use the most appropriate trait type, i.e. `.enabled(if:)` instead of `tags` for conditions

/*:
## Tests with different arguments
*/

/// 1. Avoid repetitive tests
/// 2. Stress out different permutations, with ease
/// 3. Specific arguments can be re-run from the test navigator 👌
/// 4. Run arguments in parallel, for quicker results
/// 5. View details of each argument in result
/// 3,4 and 5. All reasons to go with it without using loops over permutations

// Using a for…in loop to repeat a test (not recommended)
struct FooTestsWithArguments {
  @Test("Number of mentioned continents", arguments: [
    "A Beach",
    "By the Lake",
    "Camping in the Woods",
    "The Rolling Hills",
    "Ocean Breeze",
    "Patagonia Lake",
    "Scotland Coast",
    "China Paddy Field",
  ])
  func fooVariations(text: String) async throws {
    let foo = Foo(text: text, id: 3)
    let fooId = #require(foo.id)
    #expect(fooId >= 2)
    #expect(foo.text == text)
  }
}

/*:
## Swift Testing vs XCTest
*/

/// 1. Discovery
///   Name begins with "test" vs @Test
/// 2. Supported types
///   Instance methods vs Instance methods, static/class methods, global funcs
/// 3. Supports Traits
///   No vs Yes
/// 4. Parallel execution
///   Multi process macOS and Simulator only vs In-process, Supports devices
/// 5. Expectations
///   Tons of XCTest methods vs only #expect and #require
/// 6. Suites
///   *Types*: class vs struct, actor, class
///   *Discovery*: Subclass XCTestCase vs @Suite
///   *Before each test*: setUp(), setUpWithError(), etc, etc vs init() async throws
///   *After each test*: tearDown(), tearDownWithError(), etc, etc vs deinit()
///   *Sub-groups*: Unsupported vs Via type nesting

/*:
## Migrating from XCTest - recommended practices
*/

// Can be done incrementally, they can co-exist in the same target
// Consolidate similar XCTests into a parameterized test
// Migrate each XCTest class with only one test method to a global @Test function
// Remove redundant "test" prefixes

// Continue using XCUITest for
// 1. UI automation APIs (such as XCUIApplication)
// 2. Performance testing APIs (such as XCTMetric)
// 3. Obj-c

// Avoid
// 1. Calling `XCTAssert` from Swift Testing tests, or `#expect` from XCTests

// https://developer.apple.com/documentation/testing/migratingfromxctest


/*:
## Honorable Mentions
*/

// 1. Open source
// 2. Common codebase across all Swift supported platforms
// 3. Vs Code Swift Extension
// 4. Command line support

// command line

// $ swift test

/*:
## @Work
*/

// 1. Share knowledge
// 2. Transition to Swift Testing after adopting Xcode 16
// 3. Trial running tests via `$ swift test`
// 4. Trial tests performance vs XCTest
// 5. Tag (and potentially disable) flaky tests
// 6. Uncommented commented out tests in favor of @disabled
// 7. Define and use traits

//: [Previous](@previous) |
//: [Next](@next)
