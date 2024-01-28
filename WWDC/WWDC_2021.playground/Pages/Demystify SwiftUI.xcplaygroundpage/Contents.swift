
/*:
 # Demystify SwiftUI

 [WWDC video](https://developer.apple.com/wwdc21/10022)
*/

/*:
## Key Points
 - Identity, Lifetime and dependencies
 - Identity
  - View identity
  - Same identity = same element
  - Types of identity
    - Every view has identity, even if not explicit
    - Explicit Identity
      - UIKit and AppKit: Pointer
      - SwiftUI: value types
        - IDs; Identifiable
        - .id(someId) + scroll to view with ID
    - Structural Identity
      - Views wrapped by if-else: "True" and "False" View
      - if statements are translated into `_ConditionalContent<>` view powered by @ViewBuilder
        - i.e. _ConditionalContent<AdoptionDirectory, DogList>; `DogList` the "False" view
      - In the WWDC example a single or two conditional `PawView`s can be used to transition from bad to good state
        - Both strategies can work, but SwiftUI generally recommends single identity
        - By default try to preserve identity more fluid transitions
        - It also helps preserve the view lifetime and state
  - AnyView
    - No structure visible to SwiftUI; type eraser
    - Makes code harder to understand; Fewer compile-time diagnostics
    - Worse performance when not needed
 - Identity x lifetime
  - Continuity over time
  - Values over time; values can be properties and states of a view element
  - view value != view identity
  -



*/

//: [Previous](@previous) |
//: [Next](@next)
