/*:
 # Setters and Key Paths
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Point Free - Episode 7 - Setters and Key Paths](https://www.pointfree.co/episodes/ep7-setters-and-key-paths)

 Stephen spoke about functional setters at the Functional Swift Conference if you’re looking for more material on the topic to reinforce the ideas.
 - [Composable Setters - Stephen Celis](https://www.youtube.com/watch?v=I23AC09YnHo)

 Conal Elliott describes the setter composition we explored in this episode from first principles, using Haskell. In Haskell, the backwards composition operator `<<<`is written simply as a dot ., which means that g . f is the composition of two functions where you apply f first and then g. This means if had a nested value of type ([(A, B)], C) and wanted to create a setter that transform the B part, you would simply write it as first.map.second, and that looks eerily similar to how you would field access in the OOP style!
 - [Semantic editor combinators - Conal Elliott](http://conal.net/blog/posts/semantic-editor-combinators)
 Semantic editor combinators
*/

/*:
##  Content
*/

// MARK: - Some data to work with

struct Food {
  var name: String
}

struct Location {
  var name: String
}

struct User {
  var favoriteFoods: [Food]
  var location: Location
  var name: String
}

let user = User(
  favoriteFoods: [
    Food(name: "Tacos"),
    Food(name: "Nachos")
  ],
  location: Location(name: "Brooklyn"),
  name: "Blob"
)

User(
  favoriteFoods: user.favoriteFoods,
  location: Location(name: "Los Angeles"),
  name: user.name
)

// MARK: - Specific Property Setter - doesn't scale

func userLocationName(_ f: @escaping (String) -> String) -> (User) -> User {
  return { user in
    User(
      favoriteFoods: user.favoriteFoods,
      location: Location(name: f(user.location.name)),
      name: user.name
    )
  }
}

user
  |> userLocationName { _ in "Los Angeles" }

user
  |> userLocationName { $0 + "!" }


// MARK: - Leveraging Generics and KeyPaths for property setters

func prop<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
  -> (@escaping (Value) -> Value)
  -> (Root)
  -> Root {

  return { update in
    { root in
      var copy = root
      copy[keyPath: kp] = update(copy[keyPath: kp])
      return copy
    }
  }
}

prop(\User.name)
(prop(\User.name)) { _ in "Blobbo" }
(prop(\User.name)) { $0.uppercased() }
prop(\User.location) <<< prop(\Location.name)
prop(\User.location.name)

// Transforming user values
user
  |> (prop(\User.name)) { $0.uppercased() }
  |> (prop(\User.location.name)) { _ in "Los Angeles" }

// We can embed our user in a tuple and see this composition in action.
(42, user)
  |> (second <<< prop(\User.name)) { $0.uppercased() }

prop(\User.location) <<< prop(\.name)

user
  |> (prop(\.name)) { $0.uppercased() }
  |> (prop(\.location.name)) { _ in "Los Angeles" }

(42, user)
  |> (second <<< prop(\.name)) { $0.uppercased() }

(42, user)
  |> (second <<< prop(\.name)) { $0.uppercased() }
  |> first(incr)

prop(\User.favoriteFoods) <<< map <<< prop(\.name)

user.favoriteFoods
  .map { Food(name: $0.name + " & Salad") }

let healthier = (prop(\User.favoriteFoods) <<< map <<< prop(\.name)) {
  $0 + " & Salad"
}

user |> healthier
user |> healthier |> healthier

user
  |> healthier
  |> healthier
  |> (prop(\.location.name)) { _ in "Miami" } // "Miami"
  |> (prop(\.name)) { "Healthy " + $0 } // "Healthy Blob"

(42, user)
  |> second(healthier)
  |> second(healthier)
  |> (second <<< prop(\.location.name)) { _ in "Miami" }
  |> (second <<< prop(\.name)) { "Healthy " + $0 }
  |> first(incr)

second(healthier)
  <> second(healthier)
  <> (second <<< prop(\.location.name)) { _ in "Miami" }
  <> (second <<< prop(\.name)) { "Healthy " + $0 }
  <> first(incr)

second(
  healthier
    <> healthier
    <> (prop(\.location.name)) { _ in "Miami" }
    <> (prop(\.name)) { "Healthy " + $0 }
  )
  <> first(incr)

// MARK: - What's the point

// Configuring with expressions

let atomDateFormatter = DateFormatter()
  |> (prop(\.dateFormat)) { _ in "yyyy-MM-dd'T'HH:mm:ssZZZZZ" }
  |> (prop(\.locale)) { _ in Locale(identifier: "en_US_POSIX") }
  |> (prop(\.timeZone)) { _ in TimeZone(secondsFromGMT: 0) }

//let atomDateFormatter: DateFormatter = {
//  let atomDateFormatter = DateFormatter()
//  atomDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
//  atomDateFormatter.locale = Locale(identifier: "en_US_POSIX")
//  atomDateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//  return atomDateFormatter
//}()

// Composing with expressions

//var request = URLRequest(url: URL(string: "https://www.pointfree.co/hello")!)
//request.allHTTPHeaderFields?["Authorization"] = "Token deadbeef"
//request.allHTTPHeaderFields?["Content-Type"] = "application/json; charset=utf-8"
//request.httpMethod = "POST"

//var request = URLRequest(url: URL(string: "https://www.pointfree.co/hello")!)
//request.allHTTPHeaderFields?["Authorization"] = "Token deadbeef"
//request.allHTTPHeaderFields?["Content-Type"] = "application/json; charset=utf-8"
//request.allHTTPHeaderFields // nil
//request.httpMethod = "POST"
//request.allHTTPHeaderFields // [:]

let guaranteeHeaders = (prop(\URLRequest.allHTTPHeaderFields)) { $0 ?? [:] }

let postJson =
  guaranteeHeaders
    <> (prop(\.httpMethod)) { _ in "POST" }
    <> (prop(\.allHTTPHeaderFields) <<< map <<< prop(\.["Content-Type"])) { _ in
      "application/json; charset=utf-8"
}

let gitHubAccept =
  guaranteeHeaders
    <> (prop(\.allHTTPHeaderFields) <<< map <<< \.["Accept"]) { _ in
      "application/vnd.github.v3+json"
}

let attachAuthorization = { (token: String) in
  guaranteeHeaders
    <> (prop(\.allHTTPHeaderFields) <<< map <<< prop(\.["Authorization"])) { _ in
      "Token \(token)"
  }
}

//: [Previous](@previous) |
//: [Next](@next)
