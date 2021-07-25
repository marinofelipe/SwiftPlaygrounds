/*:
 # Protocol Witnesses: Part 1
 */

/*:
## References / Bibliografy

Heavily inspired/based on:
 - [Point Free - Episode 33](https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols/ep33-protocol-witnesses-part-1)
 - [Point Free - Episode 34](https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols/ep34-protocol-witnesses-part-2)
 - [Point Free - Episode 35](https://www.pointfree.co/episodes/ep35-advanced-protocol-witnesses-part-1)
*/

/*:
##  Content
*/

protocol Describable {
    var describe: String { get }
}

extension Int: Describable {
    var describe: String {
        "\(self)"
    }
}

2.describe // "2"

__

protocol EmptyInitializable {
    init()
}

extension String: EmptyInitializable { }
extension Array: EmptyInitializable { }
extension Int: EmptyInitializable {
//    init() {
//        self = 1
//    }
    // ⚠️ In order to make it work with Combinable as a multiplication
}

extension Optional: EmptyInitializable {
    init() {
        self = nil
    }
}

__

[1, 2, 3].reduce(0, +) // 6

extension Array {
    func reduce<Result: EmptyInitializable>(
        _ accumulation: (Result, Element) -> Result
    ) -> Result {
        self.reduce(Result(), accumulation)
    }
}

[1, 2, 3].reduce(+) // 6

// vs
[1, 2, 3].reduce(0, +) // 6

[[1, 2], [], [3, 4]].reduce(+) // [1, 2, 3, 4]
["Hello", " ", "Blob"].reduce(+) // "Hello Blob"

__

protocol Combinable {
    func combine(with other: Self) -> Self
}

extension Int: Combinable {
    func combine(with other: Int) -> Int {
        self + other
    }
}
extension String: Combinable {
    func combine(with other: String) -> String {
        self + other
    }
}
extension Array: Combinable {
    func combine(with other: Array) -> Array {
        self + other
    }
}

extension Optional: Combinable {
    func combine(with other: Optional) -> Optional {
        self ?? other // How come this is right?
//
//        switch self {
//        case .none:
//            return other
//        case let .some(value):
//            return value
//        }
    }
}

extension Array where Element: Combinable {
    func reduce(_ initial: Element) -> Element {
        reduce(initial) { $0.combine(with: $1) }
    }
}

[1, 2, 3].reduce(0)
[1, 2, 3].reduce(1)
[1, 2, 3].reduce(10)

[[1, 2],[], [3, 4]].reduce([])
[1, nil, 3].reduce(nil)
[nil, nil, 3].reduce(nil)

// MARK: - SPIKE 💡 - Or why not using AdditiveArithmetic ;)
// Instead of creating a plain new protocol where
// types doesn't conform out of the box

extension Array where Element: AdditiveArithmetic {
    func reduceWithSum(_ initial: Element) -> Element {
        reduce(initial) { $0 + $1 }
    }
}

extension Array where Element: AdditiveArithmetic {
    func reduceWithSubtraction(_ initial: Element) -> Element {
        reduce(initial) { $0 - $1 }
    }
}

extension Optional: AdditiveArithmetic where Wrapped: AdditiveArithmetic {
    public static func - (
        lhs: Optional<Wrapped>,
        rhs: Optional<Wrapped>
    ) -> Optional<Wrapped> {
        switch lhs {
        case .none:
            return rhs
        case let .some(lhsValue):
            return lhsValue - rhs
        }
    }

    public static func + (
        lhs: Optional<Wrapped>,
        rhs: Optional<Wrapped>
    ) -> Optional<Wrapped> {
        switch lhs {
        case .none:
            return rhs
        case let .some(lhsValue):
            return lhsValue + rhs
        }
    }

    public static var zero: Optional<Wrapped> { Wrapped.zero }
}

extension Array: AdditiveArithmetic where Element: AdditiveArithmetic {
    public static func - (
        lhs: Array<Element>,
        rhs: Array<Element>
    ) -> Array<Element> {
        var newArray: [Element] = lhs
        newArray -= rhs
        return newArray
    }

    public static func + (
        lhs: Array<Element>,
        rhs: Array<Element>
    ) -> Array<Element> {
        var newArray: [Element] = lhs
        newArray += rhs
        return newArray
    }

    public static var zero: Array<Element> { [Element.zero] } // or []?
}

[1, 2, 3].reduceWithSum(1)
[1, 2, 3].reduceWithSum(2)
[1, 2, 3].reduceWithSum(10)

[1, 2, 3].reduceWithSubtraction(1)
[1, 2, 3].reduceWithSubtraction(2)
[1, 2, 3].reduceWithSubtraction(10)

__

// MARK: - Protocol Composition

extension Array where Element: Combinable & EmptyInitializable {
    func reduce() -> Element {
        reduce(Element()) { $0.combine(with: $1) }
    }
}

[1, 2, 3].reduce()
[1, 2, 3].reduce()

[[1, 2],[], [3, 4]].reduce()
[1, nil, 3].reduce()
[nil, nil, 3].reduce()

// MARK: - SPIKE 💡 - Or following the spike above
// Composing with AdditiveArithmetic instead ;)

extension Array where Element: AdditiveArithmetic & EmptyInitializable {
    func reduce2() -> Element {
        reduce(Element()) { $0 + $1 }
    }
}

[1, 2, 3].reduce2()
[1, 2, 3].reduce2()

[[1, 2],[], [3, 4]].reduce2()
[1, nil, 3].reduce2()
[nil, nil, 3].reduce2()

__

// MARK: - Problems with Protocols

/// `1`. `Can only conform to them a single time per type! Is this really a problem though??`

//extension Int: Combinable {
//    func combine(with other: Int) -> Int {
//        return self * other
//    }
//}

__
// another example

struct PostgresConnInfo {
    let database: String
    let hostname: String
    var password: String
    let port: Int
    let user: String
}

let localhostPostgres = PostgresConnInfo(
    database: "pointfreeco_development",
    hostname: "localhost",
    password: "",
    port: 5432,
    user: "pointfreeco"
)

//extension PostgresConnInfo: Describable {
//    var describe: String {
//        "PostgresConnInfo(database: '\(database)', hostname: '\(hostname)', password: '\(password)', port: '\(port)', user: '\(user)')"
//    }
//}

//extension PostgresConnInfo: Describable {
//    var describe: String {
//        """
//        PostgresConnInfo(
//            database: "\(database)",
//            hostname: "\(hostname)",
//            password: "\(password)",
//            port: "\(port)",
//            user: "\(user)"
//        )
//        """
//    }
//}

extension PostgresConnInfo: Describable {
    var describe: String {
        "postgres://\(self.user):\(self.password)@\(self.hostname):\(self.port)/\(self.database)"
    }
}

print(localhostPostgres.describe)

// MARK: - Alternative for protocols

/// `- Convert a protocol into a Struct`
/// `- Promise<Unleash more composability and reusability - lets see!?>`

/// `References`

/// Modern Swift API Design - https://developer.apple.com/videos/play/wwdc2019/415/?time=778
/// ```
/// "
/// In Swift API design, like any Swift design, first explore the use case with concrete types.
/// And understand what code it is that you want to share when you find yourself repeating multiple functions on different types.
/// And then factor that shared code out using generics.
/// Now, that might mean creating new protocols.
/// But first, consider composing what you need out of existing protocols. And when you're designing protocols, make sure that they are composable.
/// And as an alternative to creating a protocol, consider creating a generic type instead.
/// "
///
/// "
/// And it's worth taking a step back for a second and saying: Was the protocol really necessary?
/// The fact that none of these conformances actually have their own custom implementation is actually kind of a warning sign that maybe the protocol isn't useful.
/// There's no per type customization going on.
/// "
///
/// "
/// This simpler extension-based approach without the protocol is a lot easier for the compiler to process.
/// And your binary sites will be smaller without a bunch of unnecessary protocol witness tables in it.
/// In fact, we've found that on very large projects, with a large number of complex protocol types,
/// we could significantly improve the compile time of those applications by taking this simplification approach and reducing the number of protocols.
/// "
///
/// "
/// And so if we were designing an API that would be easy to use, then we might consider another option,
/// which is instead of an Is-a relationship to implement as a has-a relationship.
/// That is, to wrap a SIMD value inside a generic struct.
/// So we could create instead a struct of geometric vector.
/// And we make it generic over our SIMD storage type so that it can handle any floating point type and any different number of dimensions.
/// And then once we've done this, we have much more fine-grained control over exactly what API we expose on our new type.
/// "
///```

// MARK: - Protocol-less alternative for Describable

//protocol Describable {
//    var description: String { get }
//}

// - Separate side effect
// - Easily composed
// - Value types

/// Update below on `Witnessing composition`
//struct Describing<A> {
//    var describe: (A) -> String
//}

let compactWitness = Describing<PostgresConnInfo> { conn in
  "PostgresConnInfo(database: \"\(conn.database)\", hostname: \"\(conn.hostname)\", password: \"\(conn.password)\", port: \"\(conn.port)\", user: \"\(conn.user)\")"
}

compactWitness.describe(localhostPostgres)

let prettyWitness = Describing<PostgresConnInfo> {
  """
  PostgresConnInfo(
    database: \"\($0.database)",
    hostname: \"\($0.hostname)",
    password: \"\($0.password)",
    port: \"\($0.port)",
    user: \"\($0.user)"
  )
  """
}

prettyWitness.describe(localhostPostgres)

let connectionWitness = Describing<PostgresConnInfo> {
  "postgres://\($0.user):\($0.password)@\($0.hostname):\($0.port)/\($0.database)"
}

connectionWitness.describe(localhostPostgres)

// 💡 NOTE: Downside for imperative code bases is that this alternative relies on "global "instances,
// that would have to be injected - e.g. via function or init, instead of having the behavior
// under a type as there is with Protocols

__

func print<A>(tag: String, _ value: A, _ witness: Describing<A>) {
    print("[\(tag)] \(witness.describe(value))")
}

print(tag: "debug", localhostPostgres, prettyWitness)
print(tag: "debug", localhostPostgres, connectionWitness)

// MARK: - De-protocolizing

//protocol Combinable {
//    func combine(with other: Self) -> Self
//}

struct Combining<A> {
    let combine: (A, A) -> A
}

//protocol EmptyInitializable {
//    init()
//}

struct EmptyInitializing<A> {
    let create: () -> A
}

//extension Array where Element: Combinable {
//    func reduce(_ initial: Element) -> Element {
//        reduce(initial) { $0.combine(with: $1) }
//    }
//}

extension Array {
    func reduce(_ initial: Element, _ combining: Combining<Element>) -> Element {
        return self.reduce(initial, combining.combine)
    }
}

// 💡 Opens up the world for writing different witnesses
// Lot of flexibility - Combining is used not only for sum - easily
// It also works on different types of generics out of the box
// without the need to manually conform to each of them as done before
// with Combinable (protocolized version)

let sum = Combining<Int>(combine: +)
[1, 2, 3, 4].reduce(0, sum)
// 10

let product = Combining<Int>(combine: *)
[1, 2, 3, 4].reduce(1, product)
// 24

// MARK: - De-protocolizing protocol composition

//extension Array where Element: Combinable & EmptyInitializable {
//    func reduce() -> Element {
//        reduce(Element()) { $0.combine(with: $1) }
//    }
//}

// One witness for each protocol
extension Array {
    func reduce(_ initial: EmptyInitializing<Element>, _ combining: Combining<Element>) -> Element {
        return self.reduce(initial.create(), combining.combine)
    }
}

let zero = EmptyInitializing<Int> { 0 }
[1, 2, 3, 4].reduce(zero, sum)
// 10

let one = EmptyInitializing<Int> { 1 }
[1, 2, 3, 4].reduce(one, product)
// 24

// MARK: - Reasons to 👍

// 1. Kind of like the powerful does underneath with Protocol witnesses - Interesting/Powerful to know
// 2. Reliefs the compiler and opens up a huge world of composability

// MARK: - Witnessing composition

struct Describing<A> {
    let describe: (A) -> String

    func contramap<B>(_ f: @escaping (B) -> A) -> Describing <B> {
        return Describing<B> { b in
            self.describe(f(b))
        }
    }
}

let secureCompactWitness: Describing<PostgresConnInfo> = compactWitness.contramap {
    PostgresConnInfo(
        database: $0.database,
        hostname: $0.hostname,
        password: "*******",
        port: $0.port,
        user: $0.user
    )
}

print(secureCompactWitness.describe(localhostPostgres))

//let securePrettyWitness: Describing<PostgresConnInfo> = prettyWitness.contramap {
//    PostgresConnInfo(
//        database: $0.database,
//        hostname: $0.hostname,
//        password: "*******",
//        port: $0.port,
//        user: $0.user
//    )
//}

// 💡 Now to make it even prettier

let securePrettyWitness: Describing<PostgresConnInfo> = prettyWitness
    .contramap(PostgresConnInfo.makeWithSecurePassword)

print(securePrettyWitness.describe(localhostPostgres))

extension PostgresConnInfo {
    static func makeWithSecurePassword(from other: PostgresConnInfo) -> Self {
        PostgresConnInfo(
            database: other.database,
            hostname: other.hostname,
            password: "*******",
            port: other.port,
            user: other.user
        )
    }
}

// MARK: - With past learned FP concepts 👌

// Composition would be amazing
// This is how it would look like with Overture 👇 - or the functional setters/Key Paths

//import Overture
//
//let secureCompactWitness: Describing<PostgresConnInfo> = compactWitness
//    .contramap(set(\.password, "*******"))

// e.g. with learned on Lesson 8

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

let secureCompactWitnessV2 = compactWitness // type inference also works out of the box
    .contramap(
        (prop(\PostgresConnInfo.password)) {
            pass in String(repeating: "*", count: pass.count)
        }
    )
secureCompactWitnessV2.describe(localhostPostgres)

__

// MARK: - Advanced Protocol Witnesses

// 💡 No global properties

extension Combining where A: Numeric {
    static var sum: Combining {
        .init(combine: +)
    }
    static var product: Combining {
        .init(combine: *)
    }
}

extension EmptyInitializing where A: Numeric {
    static var zero: EmptyInitializing {
        .init { 0 }
    }
    static var one: EmptyInitializing {
        .init { 1 }
    }
}

[1.1, 2, 3, 4].reduce(.zero, .sum)    // 10.1
[1.1, 2, 3, 4].reduce(.one, .product) // 26.4

__

extension Describing where A == PostgresConnInfo {
  static let compact = Describing {
    "PostgresConnInfo(database: \"\($0.database)\", hostname: \"\($0.hostname)\", password: \"\($0.password)\", port: \"\($0.port)\", user: \"\($0.user)\")"
  }

  static let pretty = Describing {
      """
      PostgresConnInfo(
        database: \"\($0.database)\",
        hostname: \"\($0.hostname)\",
        password: \"\($0.password)\",
        port: \"\($0.port)\",
        user: \"\($0.user)\"
      )
      """
  }
}

print(tag: "debug", localhostPostgres, .compact)

extension Describing where A == Bool {
    static var compact: Describing {
        .init { $0 ? "t" : "f" }
    }

    static var pretty: Describing {
        .init { $0 ? "𝓣𝓻𝓾𝓮" : "𝓕𝓪𝓵𝓼𝓮" }
    }
}

print(tag: "debug", true, .compact)
print(tag: "debug", true, .pretty)

// 💡 Composition in "data type" oriented approach is amazing and feels much more close
// to the type system than what is usually done or achievable in a Protocol oriented manner

// MARK: - Conditional conformance

//extension Array: Equatable where Element: Equatable {
//    //...
//}

//protocol Equatable {
//    static func == (lhs: Self, rhs: Self) -> Bool
//}

// "So let’s move on to seeing what other amazing things concrete types and witnesses can do.
// One of the most requested of features for Swift back in the day
// was that of “conditional conformance.” It’s what allows you to express the idea of generic
// types conforming to a protocol if the type // parameter also conforms to some protocol.
// The most classic example is that of arrays of equatable should be equatable,
// which was not possible to express until Swift 4.1, about 4 years after Swift was first announced.
//
// - Point Free - episode 35

struct Equating<A> {
    let equals: (A, A) -> Bool
}

extension Equating where A == Int {
//    static let int = Equating { $0 == $1 }
    static let int = Equating(equals: ==)
}

//func array<A>(_ equating: Equating<A>) -> Equating<[A]> {
//    .init { lhs, rhs in
//        guard lhs.count == rhs.count else { return false }
//
//        for (lhs, rhs) in zip(lhs, rhs) {
//            if !equating.equals(lhs, rhs) {
//                return false
//            }
//        }
//
//        return true
//    }
//}
//
//array(.int).equals([], [])      // true
//array(.int).equals([1], [1])   // true
//array(.int).equals([1], [1, 2]) // false

// baking that up into the type

extension Equating {
    static func array(of equating: Equating<A>) -> Equating<[A]> {
        .init { lhs, rhs in
            guard lhs.count == rhs.count else { return false }
            for (a, b) in zip(lhs, rhs) {
                if !equating.equals(a, b) { return false }
            }
            return true
        }
    }

    func pullback<B>(_ f: @escaping (B) -> A) -> Equating<B> {
        .init { lhs, rhs in
            self.equals(f(lhs), f(rhs))
        }
    }
}

Equating.array(of: .int).equals([], [])      // true
Equating.array(of: .int).equals([1], [1])    // true
Equating.array(of: .int).equals([1], [1, 2]) // false

let stringCount = Equating.int.pullback { (s: String) in s.count }
// Equating<String>

Equating.array(of: stringCount).equals([], [])                // true
Equating.array(of: stringCount).equals(["Blob"], ["Blob"])    // true
Equating.array(of: stringCount).equals(["Blob"], ["Bolb"])    // true
Equating.array(of: stringCount).equals(["Blob"], ["Blob Sr"]) // false

// and it nests

// [[Int]]

[[1, 2], [3, 4]] == [[1, 2], [3, 4, 5]] // false
[[1, 2], [3, 4]] == [[1, 2], [3, 4]]    // true

(Equating.array >>> Equating.array)(.int)

(Equating.array >>> Equating.array)(.int).equals([[1, 2], [3, 4]], [[1, 2], [3, 4]])    // true
(Equating.array >>> Equating.array)(.int).equals([[1, 2], [3, 4]], [[1, 2], [3, 4, 5]]) // false

(Equating.array >>> Equating.array)(stringCount)
    .equals([["Blob", "Blob Jr"]], [["Bolb", "Bolb Jr"]]) // true
(Equating.array >>> Equating.array)(stringCount)
    .equals([["Blob", "Blob Jr"]], [["Blob", "Bolb Esq"]]) // false

// Conditional conformance with plain functions 👆🤯

__

// MARK: - Extending tuples

//extension (Int, Int) { // Non-nominal type '(Int, Int)' cannot be extended
//    var sum: Int { return self.0 + self.1 }
//}

//extension (A, B): Equatable where A: Equatable, B: Equatable {
//    static func ==(lhs: (A, B), rhs: (A, B)) -> Bool {
//        return lhs.0 == rhs.0 && lhs.1 == rhs.1
//    }
//}

//extension Void: Equatable {
//    static func ==(lhs: Void, rhs: Void) -> Bool {
//        return true
//    }
//}

extension Equating where A == Void {
    static let void = Equating { _, _ in true }
}

Equating.array(of: .void).equals([(), ()], [(), ()]) // true
Equating.array(of: .void).equals([(), ()], [()])     // false

//[(), ()] == [()]

extension Equating {
    static func tuple<B>(_ a: Equating<A>, _ b: Equating<B>) -> Equating<(A, B)> {
        Equating<(A, B)> { lhs, rhs in
            a.equals(lhs.0, rhs.0) && b.equals(lhs.1, rhs.1)
        }
    }
}

Equating.tuple(.int, stringCount)
// Equating<(Int, String)>

Equating.tuple(.int, stringCount).equals((1, "Blob"), (1, "Bolb"))    // true
Equating.tuple(.int, stringCount).equals((1, "Blob"), (1, "Blob Jr")) // false
Equating.tuple(.int, stringCount).equals((1, "Blob"), (2, "Bolb"))    // false

// 💡 Amazing to see the power of data types for things like conditional conformance.
// Here we can make Tuples Equatable which Swift doesn't have as a language feature yet.
// And, could be done since Swift 1.

__

// MARK: - Extending functions
// "Tuples aren’t the only non-nominal types in Swift, functions are also non-nominal."

//extension (A) -> A: Combinable {
//    func combine(other f: @escaping (A) -> A) -> (A) -> A {
//        return { a in other(self(a)) }
//    }
//}

// workaround is to wrap funcs in a struct
struct Endo<A>: Combinable {
    let call: (A) -> A
    func combine(with other: Endo) -> Endo {
        Endo { a in other.call(self.call(a)) }
    }
}

// However, witnesses have no such problems

extension Combining {
    // gets to funcs from A -> A and combines then from a new one A -> A
    static var endo: Combining<(A) -> A> {
//        Combining<(A) -> A> { f, g in
//            { a in g(f(a)) }
//        }

        Combining<(A) -> A>(combine: >>>)
    }
}

extension EmptyInitializing {
    static var identity: EmptyInitializing<(A) -> A> {
        EmptyInitializing<(A) -> A> {
            { $0 }
        }
    }
}

let endos: [(Double) -> Double] = [
    { $0 + 1.0 },
    { $0 * $0 },
    sin,
    { $0 * 1000.0 }
]

endos.reduce(EmptyInitializing.identity, Combining.endo)
// (Double) -> Double

endos.reduce(EmptyInitializing.identity, Combining.endo)(3)
// -287.9033166650653

__

// MARK: - Protocol Inheritance

//protocol Comparable: Equatable {
//    static func < (lhs: Self, rhs: Self) -> Bool
//}

struct Comparing<A> {
    let equating: Equating<A>
    let compare: (A, A) -> Bool
}

let intAsc = Comparing(equating: .int, compare: <)
let intDesc = Comparing(equating: .int, compare: >)

extension Comparing {
    func pullback<B>(_ f: @escaping (B) -> A) -> Comparing<B> {
        Comparing<B>(
            equating: self.equating.pullback(f),
            compare: { lhs, rhs in
                self.compare(f(lhs), f(rhs))
            }
        )
    }
}

struct User { let id: Int, name: String }

//Three different ways of comparing users, all built from the notion of comparing integers.
// Again we’re seeing functionality that is completely impossible in the protocol world and hidden from us.
// We would never think to do things like this.

intAsc.pullback(\User.id)  // Comparing<User>
intDesc.pullback(\User.id) // Comparing<User>

intAsc.pullback(\User.name.count) // Comparing<User>

__

// MARK: - Protocol Extensions

extension Equating {
    var notEquals: (A, A) -> Bool {
        { lhs, rhs in
            !self.equals(lhs, rhs)
        }
    }
}

//public protocol Reusable {
//    static var reuseIdentifier: String { get }
//}

//public extension Reusable {
//    static var reuseIdentifier: String {
//        return String(describing: self)
//    }
//}

import UIKit

class UserCell: UITableViewCell {}
//class EpisodeCell: UITableViewCell {}
//extension UserCell: Reusable {}
//extension EpisodeCell: Reusable {}
//
//UserCell.reuseIdentifier    // "UserCell"
//EpisodeCell.reuseIdentifier // "EpisodeCell"

struct Reusing<A> {
    let reuseIdentifier: () -> String

    init(reuseIdentifier: @escaping () -> String = { String(describing: A.self) }) {
        self.reuseIdentifier = reuseIdentifier
    }
}

Reusing<UserCell>() // Reusing<UserCell>
Reusing<UserCell>().reuseIdentifier() // "UserCell"

__

// MARK: - Protocol with Associated Types

//let collections: [Collection] // 🔴 Protocol 'Collection' can only be used as a generic constraint because it has Self or associated type requirements

//public protocol RawRepresentable {
//    associatedtype RawValue
//    public init?(rawValue: Self.RawValue)
//    public var rawValue: Self.RawValue { get }
//}

enum Directions: String {
    case down = "D"
    case left = "L"
    case right = "R"
    case up = "U"
}
//
//Directions.down.rawValue // "D"
//Directions(rawValue: "D") // .some(Directions.down)
//Directions(rawValue: "X") // nil

struct RawRepresenting<A, RawValue> {
    let convert: (RawValue) -> A?
    let rawValue: (A) -> RawValue
}

// 💡 What stands out to me is that in most cases one main difference from Protocols
// is that Protocols are conformances applied to instances, while their data type
// version are static witnesses that are disconnected from instances, but instead
// just receive and do some transformation to different instances of their generics

extension RawRepresenting where A == Int, RawValue == String {
    static var stringToInt = RawRepresenting(
        convert: { Int($0) },
        rawValue: { "\($0)" }
    )
}

extension RawRepresenting where A: RawRepresentable, A.RawValue == RawValue {
    static var rawRepresentable: RawRepresenting {
        return RawRepresenting(
            convert: A.init(rawValue:),
            rawValue: \.rawValue
        )
    }
}

/// `-` We miss out the synthesized rawValue for simple enums like the example above - a lot of hassle
/// `+` ??

//extension RawRepresentable where RawValue == Int {
//    func toString() -> String {
//        "\(rawValue)"
//    }
//}

RawRepresenting<Directions, String>.rawRepresentable

//: [Previous](@previous) |
//: [Next](@next)
