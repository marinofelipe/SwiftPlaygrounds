
/*:
 # What's new in Swift

 [WWDC video](https://developer.apple.com/wwdc21/10192)
*/

/*:
## Key Points
 - Expressive code; if and switch as expressions
 - Variadic Generics (fiiinally 🙌)
  - Parameter packs
  - each and repeat
 - Swift macros
  - improve expressiveness and reduce boilerplate
  - Create macro for MVVM pattern and its components
 - Control over Copiable mechanisms
  - ‘~Copiable’ to explicitly make a type non Copiable
  - Available for structs and other value types too (enums)
 - ‘consuming’ methods
  - Define that calling it deallocates the instance
  - Gives out ownership of the value to the method called. In this case for non Copiable it means we can no longer use the value
  - By default methods in Swift borrow their arguments, including self, so you can call the right method
  - The compiler shows error messages on methods calls after consuming method calls
 - Swift Foundations written in Swift
  - Date formatting: 150% faster
  - JSON Coding: 200-500% faster
 - Actors and Concurrency
  - Granular control over actors execution
  - Executors allow setting specific DispatchQueues
*/

/*:
 ## Expressive code; if and switch as expressions
*/

let attributedName =
if let displayName, !displayName.isEmpty {
  AttributedString(markdown: displayName)
} else {
  "Untitled"
}

/*:
 ## Consuming methods
 */

struct FileDescriptor {
  private var fd: CInt

  init(descriptor: CInt) { self.fd = descriptor }

  func write(buffer: [UInt8]) throws {
    let written = buffer.withUnsafeBufferPointer {
      Darwin.write(fd, $0.baseAddress, $0.count)
    }
    // ...
  }

  consuming func close() {
    Darwin.close(fd)
  }

  deinit {
    Darwin.close(fd)
  }
}

/*:
 ## Custom actor executors
 */

actor MyConnection {
  private var database: UnsafeMutablePointer<sqlite3>
  private let queue: DispatchSerialQueue

  nonisolated var unownedExecutor: UnownedSerialExecutor { queue.asUnownedSerialExecutor() }

  init(filename: String, queue: DispatchSerialQueue) throws { … }

  func pruneOldEntries() { … }
  func fetchEntry<Entry>(named: String, type: Entry.Type) -> Entry? { … }
}

await connection.pruneOldEntries()

// Dispatch Queue conforms to Executor protocol

//protocol Executor: AnyObject, Sendable {
//    func enqueue(_ job: consuming ExecutorJob)
//}
//
//protocol SerialExecutor: Executor {
//    func asUnownedSerialExecutor() -> UnownedSerialExecutor
//    func isSameExclusiveExecutionContext(other executor: Self) -> Bool
//}
//
//extension DispatchSerialQueue: SerialExecutor { … }

//: [Previous](@previous) |
//: [Next](@next)
