/*:
 # Protocol Witnesses Exercises

 1.) Translate the Equatable protocol into an explicit datatype struct Equating.
 */

struct Equating<A> {
    let isEqualTo: (A, A) -> Bool
}

let isEqualIntWitness = Equating<Int> { lhs, rhs in
    lhs == rhs
}

isEqualIntWitness.isEqualTo(3, 2)
isEqualIntWitness.isEqualTo(0, 0)
isEqualIntWitness.isEqualTo(0, 01)

/*:
 2.) Currently in Swift (as of 4.2) there is no way to extend tuples to conform to protocols. Tuples are what is known as “non-nominal”, which means they behave differently from the types that you can define. For example, one cannot make tuples Equatable by implementing extension (A, B): Equatable where A: Equatable, B: Equatable. To get around this Swift implements overloads of == for tuples, but they aren’t truly equatable, i.e. you cannot pass a tuple of equatable values to a function wanting an equatable value.
 However, protocol witnesses have no such problem! Demonstrate this by implementing the function pair: (Combining<A>, Combining<B>) -> Combining<(A, B)>. This function allows you to construct a combining witness for a tuple given two combining witnesses for each component of the tuple.
 */

struct Combining<A> {
    let combine: (A, A) -> A

    static func pair<B>(f: Combining<A>, g: Combining<B>) -> Combining<(A, B)> {
        Combining<(A, B)> { tuple1, tuple2 in
            (
                f.combine(tuple1.0, tuple2.0),
                g.combine(tuple1.1, tuple2.1)
            )
        }
    }
}

////
extension Array {
    func reduce(_ initial: Element, _ combining: Combining<Element>) -> Element {
        return self.reduce(initial, combining.combine)
    }
}

let sum = Combining<Int>(combine: +)
[1, 2, 3, 4].reduce(0, sum)
// 10

let product = Combining<Int>(combine: *)
[1, 2, 3, 4].reduce(1, product)
// 24

let append = Combining<String>(combine: +)
["Hello", ", ", "dear"].reduce("", append)


////

let combinedTupleWitness = Combining<(Int)>
    .pair(f: sum, g: append)
print(
    combinedTupleWitness.combine(
        (3, "Hello"),
        (5, " World")
    )
)

/*:
 3.) Functions in Swift are also “non-nominal” types, which means you cannot extend them to conform to protocols. However, again, protocol witnesses have no such problem! Demonstrate this by implementing the function pointwise: (Combining<B>) -> Combining<(A) -> B>. This allows you to construct a combining witness for a function given a combining witness for the type you are mapping into. There is exactly one way to implement this function.
 */

// TODO

/*:
 4.)  One of Swift’s most requested features was “conditional conformance”, which is what allows you to express, for example, the idea that an array of equatable values should be equatable. In Swift it is written extension Array: Equatable where Element: Equatable. It took Swift nearly 4 years after its launch to provide this capability!
 So, then it may come as a surprise to you to know that “conditional conformance” was supported for protocol witnesses since the very first day Swift launched! All you need is generics. Demonstrate this by implementing a function array: (Combining<A>) -> Combining<[A]>. This is saying that conditional conformance in Swift is nothing more than a function between protocol witnesses.
 */

// TODO

/*:
 5.) Currently all of our witness values are just floating around in Swift, which may make some feel uncomfortable. There’s a very easy solution: implement witness values as static computed variables on the datatype! Try this by moving a few of the witnesses from the episode to be static variables. Also try moving the pair, pointwise and array functions to be static functions on the Combining datatype.
 */

// TODO

/*:
 6.) Protocols in Swift can have “associated types”, which are types specified in the body of a protocol but aren’t determined until a type conforms to the protocol. How does this translate to an explicit datatype to represent the protocol?
 */

// TODO

/*:
 7.) Translate the RawRepresentable protocol into an explicit datatype struct RawRepresenting. You will need to use the previous exercise to do this.
 */

// TODO

/*:
 8.) Protocols can inherit from other protocols, for example the Comparable protocol inherits from the Equatable protocol. How does this translate to an explicit datatype to represent the protocol?
 */

extension Equating where A == Int {
    static let int = Equating(isEqualTo: ==)

    static func array(of equating: Equating<A>) -> Equating<[A]> {
        .init { lhs, rhs in
            guard lhs.count == rhs.count else { return false }
            for (a, b) in zip(lhs, rhs) {
                if !equating.isEqualTo(a, b) { return false }
            }
            return true
        }
    }

    func pullback<B>(_ f: @escaping (B) -> A) -> Equating<B> {
        .init { lhs, rhs in
            self.isEqualTo(f(lhs), f(rhs))
        }
    }
}

// TODO:

/*:
 9.) Translate the Comparable protocol into an explicit datatype struct Comparing. You will need to use the previous exercise to do this.
 */

// TODO

/*:
 10.) We can combine the best of both worlds by using witnesses and having our default protocol, too. Define a DefaultDescribable protocol which provides a static member that returns a default witness of Describing<Self>. Using this protocol, define an overload of print(tag:) that doesn’t require a witness.
 */

// TODO

/*:
 11.) Currently Swift does not allow protocol methods to contain arguments with default values. For example, the following protocol is not representable in Swift:
//protocol Service {
//    func fetchUser(id: Int, cache: Bool = false) -> User?
//}

 // 🛑 Default argument not permitted in a protocol method

 Show how this can be done with a concrete data type representation of Service.
 */

struct User { let id: Int, name: String }

struct Service {
    let fetchUser: (Int, Bool) -> User?

    static func fetch(_ f: Service, cache: Bool = false) -> Service {
        .init { id, cache -> User? in
            f.fetchUser(id, cache)
        }
    }
}

let fetchUserService = Service { id, cache -> User? in
    .init(id: id, name: "name-\(id)")
}

Service.fetch(fetchUserService, cache: true)
Service.fetch(fetchUserService) // cache is false

/*:
 12.) Currently Swift does not allow protocols to extend other protocols, even if you provide all of the extensions requirements. For example, we cannot extend Numeric to be combinable even though it is easy to implement the requirement:

 extension Numeric: Combinable {
   func combine(with other: Self) -> Self {
     return self + other
   }
 }

 // 🛑 Extension of protocol 'Numeric' cannot have an inheritance clause
 Show how this can be done with a concrete data type representation of Service.
*/

struct Numeric<A> {
    let numericSum: (A, A) -> A
    let numericSubtraction: (A, A) -> A
    let combining: Combining<A>
}

//let sumNumeric = Numeric<Int>(numeric: +, combining: Combining<Int>(combine: +))
//sumNumeric.combining
