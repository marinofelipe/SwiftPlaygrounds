/*:
 # Higher Order Functions
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Point Free - Episode 5 - Higher Order Functions](https://www.pointfree.co/episodes/ep5-higher-order-functions)

 Curry function is named after Haskell Curry - mathematician that popularized the idea of currying.
 - [Haskell Curry - Wikipedia](https://en.wikipedia.org/wiki/Haskell_Curry)
*/

/*:
##  Content
*/

// MARK: - Curry

func greet(at date: Date, name: String) -> String {
  let seconds = Int(date.timeIntervalSince1970) % 60
  return "Hello \(name)! It's \(seconds) seconds past the minute."
}

func greet(at date: Date) -> (String) -> String {
  return { name in
    let seconds = Int(date.timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(seconds) seconds past the minute."
  }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in
    { b in
        f(a, b)
    }
  }
}

greet(at:name:)

curry(greet(at:name:)) // (Date, String) -> String
greet(at:)

String.init(data:encoding:)
curry(String.init(data:encoding:))
    >>> { $0(.utf8) }

__

// MARK: - Flip

func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}

let stringWithEncoding = flip(curry(String.init(data:encoding:)))

let utf8String = stringWithEncoding(.utf8) // (Data) -> String?

// MARK: - Unbound methods

"Hello".uppercased(with: Locale(identifier: "en")) // "HELLO"

String.uppercased(with:) // (String) -> (Locale?) -> String

// (Self) -> (Arguments) -> ReturnType

String.uppercased(with:)("Hello")(Locale.init(identifier: "en"))

let uppercasedWithLocale = flip(String.uppercased(with:))
let uppercasedWithEn = uppercasedWithLocale(Locale.init(identifier: "en"))

"Hello" |> uppercasedWithEn

__

"HELLO".uppercased()
String.uppercased

flip(String.uppercased) // (Optional<Foundation.Locale>) -> (String) -> String

// A version of flip with zero arguments

func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  return { { a in f(a)() } }
}

flip(String.uppercased) // () -> (String) -> String

"Hello" |> flip(String.uppercased)()

// To remove the awkward parenthesis
func zurry<A>(_ f: () -> A) -> A {
    return f()
}

"Hello" |> zurry(flip(String.uppercased))

// MARK: - High-order

/*
"We’ve gotten a lot of leverage out of curry, flip, and zurry! What’s interesting is that they’re all functions that take functions as input and produce functions as output. A lot of our composition functions do the same! These are called “higher order functions”
*/

// making free func versions of Swift's high-order funcs

[1, 2, 3]
    .map(incr)
    .map(square)

//func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> ([B]) {
//    return { $0.map(f) }
//}

Utils.map(incr)
Utils.map(square)
Utils.map(incr) >>> map(square) >>> map(String.init) // not performant
Utils.map(incr >>> square >>> String.init)

Array(1...10)
    .filter { $0 > 5 }

// With free funcs
//func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> ([A]) {
//    return { $0.filter(p) }
//}

Array(1...10)
    |> filter { $0 > 5 }
    >>> map(incr >>> square)

// MARK: - What's the point

/// Is it worth introducing these functions to our code bases?
/// **Answer:** We think so! When they work, they work really well, saving us a lot of boilerplate. When they don’t work, we’re still using the concepts and building intuitions for them. The ideas of currying and flipping are simple, and they’re going to unlock a lot of composition in the future.

//: [Previous](@previous) |
//: [Next](@next)
