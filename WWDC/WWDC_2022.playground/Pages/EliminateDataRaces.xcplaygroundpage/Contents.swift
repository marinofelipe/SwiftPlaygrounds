import _Concurrency
import Foundation

/*:
 # Eliminate data races with Swift Concurrency

 [WWDC video](https://developer.apple.com/videos/play/wwdc2022/110351)
 */

/*:
 ## Key Points
 - async/await, structured concurrency, actors
 - A model for data races free program
 - ,
 */

// MARK: - Task isolation

// In sea of concurrency, tasks are represented by boats
// Tasks are sequential, asynchronous and self-contained
// When tasks access the same data, each gets its own copy (value type)

struct Egg {}

enum HungerLevel {
  case low, mid, high
}

class Chicken {
  let name: String
  var currentHunger: HungerLevel

  func feed() {}
  func play() {}
  func produce() -> Egg { .init() }

  init(name: String, currentHunger: HungerLevel = .low) {
    self.name = name
    self.currentHunger = currentHunger
  }
}

// The `Sendable` protocol describes types that can cross an isolation domain

struct Pineapple: Sendable {} // sythesized because it's a value type

//final class Fish: Sendable {} // compile error, because it's a reference type

// reference types are only Sendable when they are final and have immutable data

final class Goat: Sendable {
  let name: String

  init(name: String) {
    self.name = name
  }
}

// a type can have synchronization mechanisms, such as a lock, but Swift can't infer that. For that
// there's the `@unchecked Sendable` conformance. !! Be careful !!

class ConcurrentCache<Key: Hashable & Sendable, Value: Sendable>: @unchecked Sendable {
  var lock: NSLock
  var storage: [Key: Value]

  init(lock: NSLock, storage: [Key: Value]) {
    self.lock = lock
    self.storage = storage
  }
}

let lily = Chicken(name: "Lily")
Task.detached {
  await lily.feed()
}

// Sendable checking maintains task isolation

// MARK: - Actor isolation

// Isolate and coordinate access to shared/non isolated data

// All instant properties and instant methods of an actor are isolated by default

actor Island {
  var flock: [Chicken]
  var food: [Pineapple]

  init(flock: [Chicken], food: [Pineapple]) {
    self.flock = flock
    self.food = food
  }

  func advanceTime() {
    // the non-isolated reduce func inherits isolation from the actor
    let totalSlices = food.indices.reduce(0) { (total, nextIndex) in
      total + food[nextIndex].slice()
    }

    // and so does the unstructured Tasks
    Task {
      flock.map(Chicken.produce)
    }

    // however, **detached** tasks do not inherit the actor isolation, they are completely
    // detached of the context
    Task.detached {
      let ripePineapples = await food.filter { $0.ripeness == .perfect }
      print("There are \(ripePineapples.count) ripe pineapples on the island")
    }
  }

  func addToFlock(_ flock: Chicken) {
    self.flock.append(flock)
  }

  func adoptPet() -> Chicken {
    flock.remove(at: 0)
  }
}

// actors make sure only one task access it at a time, they isolate all their internal mutable state
// actors are implicit Sendable

// Non-`Sendable` data cannot be shared between a task and an actor

func nextRound(islands: [Island]) async {
  for island in islands {
    await island.advanceTime()
  }
}

// Both examples cannot be shared
let myIsland = Island(flock: [], food: [])
await myIsland.addToFlock(lily)
let myChicken = await myIsland.adoptPet()

// actors can have non isolated methods
// for that the `await` is needed
// such non-isolated async code executes on the global cooperative pool

extension Island {
  nonisolated func meetTheFlock() async {
    let flockNames = await flock.map { $0.name } // fails to compile because Chicken(flock) is non-sendable, and therefore exclusive to the island
    print("Meet our fabulous flock: \(flockNames)")
  }
}

// Non-isolated synchronous code
// it's okay in this case because even though it's a free function, it gets called from the
// isolated Island code

func greet(_ friend: Chicken) { }

extension Island {
  func greetOne() {
    if let friend = flock.randomElement() {
      greet(friend)
    }
  }
}

// if the used greet func was a non-isolated async function

func greetAny(flock: [Chicken]) async {
  if let friend = flock.randomElement() {
    greet(friend)
  }
}

// Each actor instance is isolated from everything else in the program
// Only one Task can execute on an actor at a time

// @MainActor
// "UI land", the serial UI pool, run a single job at a time

@MainActor func updateView() {}

Task { @MainActor in
  // …
  view.selectedChicken = lily
}

nonisolated func computeAndUpdate() async {
  computeNewValues()
  await updateView()
}

// Views, View Controllers, and View models, because are bound to the view layer are
// good candidates for @MainActor isolation

// MARK: - Atomicity

func deposit(pineapples: [Pineapple], onto island: Island) async {
  var food = await island.food
  food += pineapples
  await island.food = food
}

// running it on the actor will guarantee the mutation is done
// on the isolated context

extension Island {
  func deposit(pineapples: [Pineapple]) {
    var food = self.food
    food += pineapples
    self.food = food
  }
}

// 💡 think transactionally
// identify synchronous operations that can be interleaved

// MARK: - Ordering

// Swift concurrency provides tools for ordering operations,
// actors is not one of them
// Actors execute the highest-priority work first
// Important semantic difference vs serial Dispatch queues

// 1. Tasks run code in order
// 2. `AsyncStream`s deliver elements in order

// Concurrency checking

import FarmAnimals

struct Coop: Sendable {
  var flock: [Chicken]
}

// when using models that are not Sendable
// add `@preconcurrency import` to shut down concurrency errors, before
// code is migrated to Swift 6

@preconcurrency import FarmAnimals

func visit(coop: Coop) async {
  guard let favorite = coop.flock.randomElement() else {
    return
  }

  Task {
    favorite.play()
  }
}








//: [Previous](@previous) |
//: [Next](@next)
