/*:
 # Observation series

 Episodes:
 - https://www.pointfree.co/episodes/ep252-observation-the-past
 - https://www.pointfree.co/episodes/ep253-observation-the-present
 - https://www.pointfree.co/episodes/ep254-observation-the-gotchas
 - https://www.pointfree.co/episodes/ep255-observation-the-future
*/

import SwiftUI

// MARK: - The Past

/// `> either leading you to observe too much state causing inefficient views, or observe too little state causing glitchy views.`

// MARK: @State

// persisted across multiple instances of the struct
// the property wrapper has a long living reference type stored value
//
// A @State only recompiles the body when it affects the view hierarchy
// or if used on view logic, like an if-else condition

// MARK: Side effects

// Can be performed without affecting the view only within closures

struct CounterView: View {
  // persisted across multiple instances of the struct
  // the property wrapper has a long living reference type stored value
  //
  // A @State only recompiles the body when it affects the view hierarchy
  // or if used on view logic, like an if-else condition
  @State var count = 0
  @State var secondsElapsed = 0

  var body: some View {
    let _ = Self._printChanges()

    Form {
      Section {
        Text(self.count.description)
        Button("Decrement") { self.count -= 1 }
        Button("Increment") { self.count += 1 }
      } header: {
        Text("Counter")
      }
    }
  }
}

// MARK: Rules of thumb

/// Both behaviour and state should be not within the view
/// State should be within the view model
///
/// @State gets recreated every time the parent recomputes its body
/// @StateObject does not
/// in iOS 17 @StateObject is not even needed ?
///
/// @StateObject, @ObservedObject are needed for the view to observe the internals of a class (ie view model)

// MARK: ObservableObject gotcha

/// @ObservableObject can get tricky
///
/// Have to pick props that should be Published
/// - leaving some out may lead the view not updating when needed
/// - making some that shouldn't be Published may update the view unnecessarily
///
/// - note: @Published updates the view when changes, even when not directly used by the view

// MARK: Composition

/// @ObservableObject for a parent model can't easily observe state changes of child
///
/// For example on a root model that holds 3 tabs, which with their own model
///
/// Solutions
/// 1. Use `child.objectWillChange.sink` on the child models and bind that to `self.objectWillChange.send`
///   - Verbose, too manual, and hack-ish
/// 2. Some folks in the community created `@Republished` to solve `1` in a clear manner
///   - It makes far too easy to observe too much state of the child view
///   - The parent views get updated unnecessarily, whenever a child publishes changes, even when not used by the parent
///   - _To mitigate_: Use `child.$publishedProp.sink` instead
///     - Requires it for each prop
///     - The parent must know exactly what to observe, and the child exactly what to make observable for the parent, which makes even more complex
///

// MARK: - The Present

import Observation

// unattached from SwiftUI

@Observable
final class CounterViewModel {

}

// way smarter, view gets recomputed only when really needed
// Observing changes from inner models just works
// AppModel
  // CounterModel
  // CounterModel
  // CounterModel
// observed changes through parent, like `appModel.counter.state`, just work
// they get sent through, and only that specific piece of state changes

struct CounterView_Obs: View {
  // no property wrappers needed
  let model = CounterViewModel()

//  @Bindable var model: CounterViewModel
  // for two way binding of the model
  // for when it is provided by the parent and the child can update

  var body: some View {
    Text("")
  }
}

// Observation downsides
// - no operators like in Combine (Published)
// - withObservationTracking is very raw
// - mitigate: use plain Swift code to operate over the data, ie didSet over props

// MARK: - The Gotchas

@Observable
struct Some {
  let id: String
}

class CounterModel_Gotchas {
  private var count = 0

  func observe() {
    withObservationTracking {
      _ = self.count
    } onChange: { // willset
      // hard to guarantee the order of execution
      // even by wrapping in a @MainActor Task (async on Main)

      print("Do something with", self.count)
      self.observe()
    }
  }
}

// Gotcha 2 - ⚠️ No warnings when the UI is not updated on Main

// Gotcha 3 - No support for value types
// reference types don't have synthesized Equatable/Hashable conformance
// custom Equatable conformances come with complications, like fields that have equality based on
// pointers or identity
// in general, value types is a great Swift feature, that is unfortunately not supported
// *ideally, the custom conformances compare the pointers/instances and hash the ObjectIdentifier(self)
// the Swift compiler prevents a lot of pitfalls when using value types, such as structured concurrency
// safeguards that don't easily apply to value types
// Gotcha 3.1 - On Collection types like Arrays, if one element is changed, observation emits events
// to all observed elements of the array, the same goes for any inner props of it
// *This would be fine if Swift.Array was itself @Observable
//
// This limits any cases with large data structures and nested types that are not @Observable

// MARK: - The Future



//: [Previous](@previous) |
//: [Next](@next)
