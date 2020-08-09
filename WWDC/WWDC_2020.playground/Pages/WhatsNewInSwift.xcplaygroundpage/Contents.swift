
/*:
 # What's new in Swift

 Add sessions callout here.
*/

/*:
## Key Points
 * Swift 5 binary size is only 1.5 times the Objc one
 * SwiftUI binary size drastically reduced =~ 40%
 * Swift has a much better memory allocation layout than Objc, since relies on value types.
    * Uses less blocks of memory. Heap usage is =~ 55% than Objc in Swift 5.1
    * Even then, until 5.1, Swift programs usually took more heap memory than Objc, due to runtime overhead
        * Number of caches in memory at start up - types information, protocol conformances, bridge types
    * 5.3 was drastically improved - less than a third of 5.1 heap usage - _Note_: This will improve only for apps with deployment target from iOS 14
 * Diagnostics improved - more assertive on SwiftUI
 * Code completion way faster x15 - from Source Kit LSP to Xcode
 * Code indentation also improved - PS: Also for multiline `guard`, `if`, `while` conditions 🤞
 * LLDB has a fallback which will *potentially* make it more robust to debug Swift code
 * Windows official support coming on Swift 5.3
 * Swift EVOlution
    * SE-0281 - Multiple trailing closure syntax
        * Allow deciding on call site when to drop the argument label for many trailing closures
        * When dropping, the function name can help on guiding what to expect from the first trailing closure
    * SE-0249 - Key path expressions as functions
        * Allow passing in KeyPath expressions as functions when the signature matches
    * SE-0281 - @main
        * Simplify how to start up a program. It creates a main.swift file in the behalf of the user, when tagged as main.
        * Standardized way to delegate the program's entry point.
        * Work for all kind of applications: command line, new and old iOS/mac apps.
        * Declarative
    * SE-0269 - Increased availability of implicit self in closures
         * Self can be captured in the capture list and omitted from the closure body
         * Less redundant
         * Standard way to capture self, strongly `self`, `unowned`, or `weak`
         * For value types, since reference cycles are unlikely, the compiler allows omitting self completely
     * SE-0276 - Multi-pattern catch clauses
         * No need for nested switch clauses
         * Allow flatten multi-clauses pattern matching directly into the catch statement
 * Enums
    * SE-0266 - Enums Comparable conformance
    * SE-0280 - Enum  cases as Protocol Witnesses
    * Can be used to fulfill `static var and static func` from protocol requirements
 * Embedded DSL enhancements
    * Allow pattern matching control flow statements
        * Switch-case
        * if-let
    * Builder inference
        * Compiler is able to infer the builder type based on the protocol requirement - e.g. @SceneBuilder for the App struct
 * SDK changes
    * Float16
        * IEEE 754 standard format
        * Takes only two bytes - half-width floating point type
        * Significant performance gains
        * Low precisions, small range - careful when migrating code
  * Apple Archive
    * Modular archive format
    * Fast, multi-threaded compression
 * Swift system
    * Idiomatic Swift interfaces for system calls
    * Replaces FileManager `??`
 * OSLog
    * High-performance, privacy-sensitive logging
    * Added options for formatting and String interpolation
 * Packages
    * Swift Numerics
        * `github.com/apple/swift-numerics`
        * Basic math for generic contexts, and complex numbers and algorithm
    * Swift ArgumentParser
        * `github.com/apple/swift-argument-parser`
        * Build-in documentation, nice property wrappers
    * Swift StandardLibraryPreview
        * `github.com/apple/swift-standard-library-preview`
        * Early access to new StandardLibrary features
*/

/*:
##  Learnings and Thoughts
*/

/*:
###  SE-0281
 Increased availability of implicit self in closures
*/

struct AnyCode { }

//: [Previous](@previous) |
//: [Next](@next)
