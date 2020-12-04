/*:
 # Setters and Key Paths - Exercises
*/

/*:
 1. In this episode we used Dictionary’s subscript key path without explaining it much. For a key: Key, one can construct a key path \.[key] for setting a value associated with key. What is the signature of the setter prop(\.[key])? Explain the difference between this setter and the setter prop(\.[key]) <<< map, where map is the optional map.
*/

let dict: [String: Any] = ["Header": "Some"]
let kp = \[String: Any].["Header"]
let header = dict[keyPath: kp]

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

let propolis = prop(\[String: Any].["Header"])
// ((Optional<Any>) -> Optional<Any>) -> (Dictionary<String, Any>) -> Dictionary<String, Any>
// ((Value?) -> Value?) -> [Key: Value] -> [Key: Value]

let mappedPropolis = prop(\[String: Any].["Header"]) <<< map

// ((Any) -> Any) -> (Dictionary<String, Any>) -> Dictionary<String, Any>
// ((Value) -> Value) -> [Key: Value] -> [Key: Value]. The prop(\.[key])

/*:
 The Set<A> type in Swift does not have any key paths that we can use for adding and removing values. However, that shouldn’t stop us from defining a functional setter! Define a function elem with signature (A) -> ((Bool) -> Bool) -> (Set<A>) -> Set<A>, which is a functional setter that allows one to add and remove a value a: A to a set by providing a transformation (Bool) -> Bool, where the input determines if the value is already in the set and the output determines if the value should be included.
 */

let set: Set<Int> = [1, 2, 2]
set[keyPath: \.first] //?

func elem<A>(_ a: A) -> (@escaping (Bool) -> Bool) -> (Set<A>) -> Set<A> {
    return { shouldInclude in
        { set in
            if shouldInclude(set.contains(a)) {
                return set.union(Set([a]))
            } else {
                return set.subtracting(Set([a]))
            }
        }
    }
}

let hasTheElementTwo = elem(2)

let otherSet = set
    |> (hasTheElementTwo) { _ in false }
    |> (elem(1)) { hasElement in hasElement == false }
    |> (elem(3)) { _ in true }
    |> (elem(1)) { _ in true }

dump(
    otherSet
)

/*:
 Generalizing exercise #1 a bit, it turns out that all subscript methods on a type get a compiler generated key path. Use array’s subscript key path to uppercase the first favorite food for a user. What happens if the user’s favorite food array is empty?
 */

let favoriteFood: [String] = ["Shnitzel" ,"Pizza", "Burger"]

let firstItemFunctionalSetter = prop(\[String].[0])

favoriteFood
    |> firstItemFunctionalSetter { $0.uppercased() }

let dontEatAtAll: [String] = []
//dontEatAtAll
//    |> firstItemFunctionalSetter { $0.uppercased() }
// A: When the array is empty there's a compiler warning

/*:
Recall from a previous episode that the free filter function on arrays has the signature ((A) -> Bool) -> ([A]) -> [A]. That’s kinda setter-like! What does the composed setter prop(\User.favoriteFoods) <<< filter represent?
 */

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

let composedSetter = prop(\User.favoriteFoods) <<< filter
composedSetter // ((@escaping (Food) -> Bool) -> (User) -> User

let user = User(
    favoriteFoods: [
        .init(name: "salmon")
    ],
    location: .init(name: "Berlin"),
    name: "Felipo"
)

user
    |> composedSetter { $0.name.starts(with: "s") }

/*:
 Define the Result<Value, Error> type, and create value and error setters for safely traversing into those cases.
 */

func value<Value, Error>(_ f: @escaping (Value) -> Value) -> (Result<Value, Error>) -> Result<Value, Error> {
    return { result in
        switch result {
            case let .success(value):
                return .success(f(value))
            case .failure:
                return result
        }
    }
}

func error<Value, Error>(_ f: @escaping (Error) -> Error) -> (Result<Value, Error>) -> Result<Value, Error> {
    return { result in
        switch result {
            case .success:
                return result
            case let .failure(error):
                return .failure(f(error))
        }
    }
}

let result: Result<Int, URLError> = .success(10)

result
    |> value { $0 + 10 }
    |> error { _ in .init(.callIsActive) }

/*:
Is it possible to make key path setters work with enums?
*/

// A: Not yet! Swift doesn't give access to key paths for enums, but only for structs and classes.

/*:
Redefine some of our setters in terms of inout. How does the type signature and composition change?
*/

// Result inout setters

func value<Value, Error>(_ f: @escaping (inout Value) -> Void) -> (Result<Value, Error>) -> Result<Value, Error> {
    return { result in
        switch result {
            case let .success(value):
                var valueCopy = value
                f(&valueCopy)
                return .success(value)
            case .failure:
                return result
        }
    }
}

func error<Value, Error>(_ f: @escaping (inout Error) -> Void) -> (Result<Value, Error>) -> Result<Value, Error> {
    return { result in
        switch result {
            case .success:
                return result
            case let .failure(error):
                var errorCopy = error
                f(&errorCopy)
                return .failure(error)
        }
    }
}

let otherResult: Result<Int, URLError> = .failure(.init(.badServerResponse))

otherResult
    |> value { value in value += 10 }
    |> error { error in print(error) }

// prop inout setter

func inoutProp<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
-> (@escaping (inout Value) -> Void)
-> (Root)
-> Root {
    return { update in
        { root in
            var copy = root
            update(&copy[keyPath: kp])
            return copy
        }
    }
}

var otherUser = user

let yetAnotherUser = otherUser
    |> (inoutProp(\User.favoriteFoods)) { $0 = [.init(name: "Strogonoff & Bife")] }
    |> (inoutProp(\User.name)) { $0 = "Artur & Pedro" }
    |> (inoutProp(\User.location)) { $0 = .init(name: "SP") }

dump(otherUser)
dump(yetAnotherUser)

// PointFree's way - Root as inout as well

func fullInoutProp<Root, Value>(_ kp: WritableKeyPath<Root, Value>)
-> (@escaping (inout Value) -> Void)
-> (inout Root) -> Void {
    return { update in
        { root in
            update(&root[keyPath: kp])
        }
    }
}

//var someUsa = user
//
//(
//    someUsa
//        <> (fullInoutProp(\User.favoriteFoods)) { $0 = [.init(name: "Strogonoff & Bife")] }
//        <> (fullInoutProp(\User.name)) { $0 = "Artur & Pedro" }
//        <> (fullInoutProp(\User.location)) { $0 = .init(name: "SP") }
//)

//: [Previous](@previous) |
//: [Next](@next)
