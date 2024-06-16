/*:
 # Beyond The Basics Of Structured Concurrency

 [WWDC video](https://developer.apple.com/wwdc23/10170)
*/

/*:
## Key Points
 - Structured vs Unstructured Concurrency
  - TaskGroup vs Task.detached
  - Prefer structured
  - The benefits of structured concurrency not always applies to unstructured tasks
  - async let vs Task
 - Task cancellation

*/

// MARK: - Task Tree

// make soup
  // chop ingredients
    // chop 🥕
    // chop 🧅
    // chop 🍅
  // marinate 🍗
  // bold broth

// MARK: - cancellation

Task.checkCancellation() // checks if the task is cancelled, and throws if so

// can't guarantee the order of operations in an actor

// Swift Atomics can be useful to manage access to a prop
// https://github.com/apple/swift-atomics
// mainly for system engineers
  // This package exists to support the few cases where the use of atomics is unavoidable -- such as when implementing those high-level synchronization/concurrency constructs.
  // The primary focus is to provide systems programmers access to atomic operations with an API design that emphasizes clarity over superficial convenience:

// MARK: - priority

// child task inherit parent's priority
// also when escalated


func run async throws {
  // automatically releases resources and cancel tasks in the group
  withThrowingDiscardingTaskGroup { group in
    group.addTask {
      try await Task.sleep(forTimeInterval: .exponentBitCount)
    }
  }
}

// MARK: - task-local value

actor Kitchen {
  @TaskLocal static var orderID: Int?
  @TaskLocal static var cook: String?

  func logStatus() {
    print("current cook: \(Kitchen.cook ?? "none")")
  }
}

let kitchen = Kitchen()
await kitchen.logStatus()
await Kitchen.$cook.withValue("Sakura") { // assigned and bound for the duration of the given scope*
  await kitchen.logStatus()
}
await kitchen.logStatus()

//*to find the value of a LocalTask the hierarchy tree is inversely traversed, until a value is found
//**the Swift runtime has a reference to the task the local value reference to, so it doesn't have to traverse
//the whole tree

// MARK: - tracing

// OSLog and metadata providers
// Task-local values
  // attach metadata to the current task
  // inherited by child tasks as well as Task {}
  // low-level building block for context propagation

// Concurrency Instruments

// Swift Distributed Tracing package
  // allows to trace what happens in the server


//: [Previous](@previous) |
//: [Next](@next)
