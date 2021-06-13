
/*:
 # What's new in Swift

 [WWDC video](https://developer.apple.com/wwdc21/10192)
*/

/*:
## Key Points
 - Swift Diversity
 - Package collections
    - Xcode
    - CLI
    - Curated list
    - JSON file
    - `Watch`: [Discover and curate Swift packages using collections - WWDC 21](    https://developer.apple.com/videos/play/wwdc2021/10197)
 - New open source Packages
    - Swift Collections - *common set of data structures*
        - Deque
            - Like `Array`. Supports *efficient* operations on both boundaries.
        - OrderedSet
            - Powerful mix of `Set` and `Array`
        - OrderedDictionary
            - Custom Dictionary where `order matters` & with support for random access.
    - Swift Algorithms - *sequence and collection algorithms*
        - Over 40 algorithms
        - e.g. permutations; random, combinations
    - Swift System - *Idiomatic, low level interfaces to system calls*
        - e.g. Powerful FilePath API
        - e.g. Powerful FilePath API
    - Swift Numerics
        - Float 16
        - Complex numbers
    - Swift Argument parser - *enhanced*
        - Fish shell
        - Improved error messages
 - Server side
    - AWS improvements - `async` support
 - Developer experience
    - `DocC` - to be open source at end of the year
    - Related WWDC talks:
        - [Meet DocC documentation in Xcode](https://developer.apple.com/videos/play/wwdc2021/10166/)
        - [Elevate your DocC documentation in Xcode](https://developer.apple.com/videos/play/wwdc2021/10167)
        - [Host and automate your DocC documentation](https://developer.apple.com/videos/play/wwdc2021/10236/)
        - [Build interactive tutorials using DocC
](https://developer.apple.com/videos/play/wwdc2021/10235/)
    - Incremental builds
        - `Incremental imports`
            - No longer re build every source file that imports a module when that module changes
        - `Faster` startup time before *launching compiles*
            - Compute module dependency graph up front
        - `Fewer` recompilations after changing an extension body
    - Xcode 13 uses a new version of the compiler that has a part written in Swift - *Swift driver project*
 - Memory management
    - Changes in the compiler that optimizes memory management
    - `New` build setting - *Optimize Object Lifetime* - more aggressive optimization
    - Related talk: [ARC in Swift: Basics and Beyond](https://developer.apple.com/videos/play/wwdc2021/10216/)
 - Swift 5.5 features
    - Ergonomic improvements
        - [SE-0293](https://github.com/apple/swift-evolution/blob/main/proposals/0293-extend-property-wrappers-to-function-and-closure-parameters.md) - Property wrappers extended to function and closure params
    - Async and concurrency
        - async / await
        - async let for local concurrent child tasks
        - actors to for thread safety
*/

//: [Previous](@previous) |
//: [Next](@next)
