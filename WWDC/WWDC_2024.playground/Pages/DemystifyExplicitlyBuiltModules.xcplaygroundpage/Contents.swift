/*:
 # Demystify Explicitly Built Modules

 [WWDC video](https://developer.apple.com/wwdc24/10171)
*/

/*:
## Key Points
 - Scan, Build Modules and then build source code
 - It can now avoid filling execution lanes with tasks that are not ready to run
 - Build are more precise and deterministic
 - Start up can also be speed up by passing modules to the debugger
 - On projects built with implicitly built models, the Xcode build and the debugger have completely separate module graphs
 - With explicitly built models, the debugger is now able to reuse the already built modules
 - Build system in control
 - Reduce module variants by moving settings up in scope
*/


//: [Previous](@previous) |
//: [Next](@next)
