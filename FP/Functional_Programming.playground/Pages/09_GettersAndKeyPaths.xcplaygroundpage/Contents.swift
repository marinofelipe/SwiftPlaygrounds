/*:
 # Getters and Key Paths
*/

/*:
## References / Bibliografy

Based on:
 - [Point Free - Episode 8 - Getters and Key Paths](https://www.pointfree.co/episodes/ep8-getters-and-key-paths)

 SE-0249 - Key Path Expressions as Functions
 - [Composable Setters - Stephen Celis](https://www.youtube.com/watch?v=I23AC09YnHo)

 "A proposal has been accepted in the Swift evolution process that would allow key paths to be automatically promoted to getter functions. This would allow using key paths in much the same way you would use functions, but perhaps more succinctly: users.map(\.name)."
 https://forums.swift.org/t/se-0249-key-path-expressions-as-functions/21780
*/

/*:
##  Content
*/

struct User {
  let id: Int
  let email: String
}

let user = User(id: 1, email: "blob@pointfree.co")
user.id
user.email

let f = { (user: User) in user.id } >>> String.init

\User.id // KeyPath<User, Int>
user[keyPath: \User.id]
user.id

func get<Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
  return { root in
    root[keyPath: kp]
  }
}

get(\User.id) >>> String.init


extension User {
  var isStaff: Bool {
    return self.email.hasSuffix("@pointfree.co")
  }
}

user.isStaff

\User.isStaff
user[keyPath: \User.isStaff]

get(\User.isStaff)


let users = [
  User(id: 1, email: "blob@pointfree.co"),
  User(id: 2, email: "protocol.me.maybe@appleco.example"),
  User(id: 3, email: "bee@co.domain"),
  User(id: 4, email: "a.morphism@category.theory")
]

users
  .map { $0.email }

//users
//  .map(\User.email)

extension Sequence {
  func map<Value>(_ kp: KeyPath<Element, Value>) -> [Value] {
    return self.map { $0[keyPath: kp] }
  }
}

users
  .map(\User.email)
users
  .map(\.email)
//users
//  .filter(\.isStaff)
users
  .map(get(\.email))

users
  .filter(get(\.isStaff))

users
  .map(get(\.email))
  .map(get(\.count))

users
  .map(get(\.email) >>> get(\.count))


users
  .map(get(\.email.count))

users
  .filter(get(\.isStaff) >>> (!))


users
  .filter((!) <<< get(\.isStaff))

users
  .sorted(by: { $0.email.count < $1.email.count })

//users.sorted(by: <#T##(User, User) throws -> Bool#>)
func their<Root, Value>(_ f: @escaping (Root) -> Value, _ g: @escaping (Value, Value) -> Bool) -> (Root, Root) -> Bool {

  return { g(f($0), f($1)) }
}


users
  .sorted(by: their(get(\.email), <))

users
  .sorted(by: their(get(\.email), >))

users
  .sorted(by: their(get(\.email.count), >))

users
  .max(by: their(get(\.email), <))?.email

users
  .min(by: their(get(\.email), <))?.email

func their<Root, Value: Comparable>(_ f: @escaping (Root) -> Value) -> (Root, Root) -> Bool {

  return their(f, <)
}

users
  .max(by: their(get(\.email)))?.email

users
  .min(by: their(get(\.email)))?.email


[1, 2, 3]
  .reduce(0, +)


struct Episode {
  let title: String
  let viewCount: Int
}

let episodes = [
  Episode(title: "Functions", viewCount: 961),
  Episode(title: "Side Effects", viewCount: 841),
  Episode(title: "UIKit Styling with Functions", viewCount: 1089),
  Episode(title: "Algebraic Data Types", viewCount: 729),
]

episodes
  .reduce(0) { $0 + $1.viewCount }

func combining<Root, Value>(
  _ f: @escaping (Root) -> Value,
  by g: @escaping (Value, Value) -> Value
  )
  -> (Value, Root)
  -> Value {

    return { value, root in
      g(value, f(root))
    }
}

episodes.reduce(0, combining(get(\.viewCount), by: +))



prefix operator ^
prefix func ^ <Root, Value>(_ kp: KeyPath<Root, Value>) -> (Root) -> Value {
  return get(kp)
}

^\User.id
users.map(^\.id)

users.map(^\.email.count)
users.map(^\.email.count >>> String.init)

users.filter(^\.isStaff)
users.filter((!) <<< ^\.isStaff)

users.sorted(by: their(^\.email))
users.sorted(by: their(^\.email, >))

users.max(by: their(^\.email.count))?.email
users.min(by: their(^\.email.count))?.email

//: [Previous](@previous) |
//: [Next](@next)
