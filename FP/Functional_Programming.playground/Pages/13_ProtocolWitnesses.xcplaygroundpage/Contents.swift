/*:
 # Protocol Witnesses: Part 1
 */

/*:
## References / Bibliografy

Heavily inspired/based on:
 - [Point Free - Episode 33](https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols/ep33-protocol-witnesses-part-1)
 - [Point Free - Episode 34](https://www.pointfree.co/collections/protocol-witnesses/alternatives-to-protocols/ep34-protocol-witnesses-part-2)
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

//: [Previous](@previous) |
//: [Next](@next)
