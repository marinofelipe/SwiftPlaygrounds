/*:
 # Functional Setters
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Point Free - Episode 6 - Functional Setters](https://www.pointfree.co/episodes/ep6-functional-setters)

 Stephen spoke about functional setters at the Functional Swift Conference if you’re looking for more material on the topic to reinforce the ideas.
 - [Composable Setters - Stephen Celis](https://www.youtube.com/watch?v=I23AC09YnHo)

 Conal Elliott describes the setter composition we explored in this episode from first principles, using Haskell. In Haskell, the backwards composition operator `<<<`is written simply as a dot ., which means that g . f is the composition of two functions where you apply f first and then g. This means if had a nested value of type ([(A, B)], C) and wanted to create a setter that transform the B part, you would simply write it as first.map.second, and that looks eerily similar to how you would field access in the OOP style!
 - [Semantic editor combinators - Conal Elliott](http://conal.net/blog/posts/semantic-editor-combinators)
 Semantic editor combinators
*/

/*:
##  Content
*/

let pair = (42, "Swift")

(incr(pair.0), pair.1)

func incrFirst<A>(_ pair: (Int, A)) -> (Int, A) {
    (incr(pair.0), pair.1)
}

incrFirst(pair)

func first<A, B, C>(_ f: @escaping (A) -> C) -> ((A, B)) -> (C, B) {
    return { pair in
        (f(pair.0), pair.1)
    }
}

first(incr)(pair)
pair
    |> first(incr)
    |> first(String.init)

func second<A, B, C>(_ f: @escaping (B) -> C) -> ((A, B)) -> (A, C) {
    return { pair in
        (pair.0, f(pair.1))
    }
}

pair
    |> first(incr)
    |> second(String.uppercased)

pair
    |> first(incr)
    |> first(String.init)
    |> second(zurry(flip(String.uppercased)))

let composedFunc = first(incr)
    >>> first(String.init)
    >>> second(zurry(flip(String.uppercased)))

composedFunc(pair)

pair |>
    first(incr)
    >>> first(String.init)
    >>> second(zurry(flip(String.uppercased)))

pair |>
    first(incr >>> String.init)
    >>> second(zurry(flip(String.uppercased)))


// achieve the same with imperative
var copyPair = pair
copyPair.0 += 1
//copyPair.0 = String(copyPair.0) -> Not able to transform the data, would have to create a different pair object, composed by (String, String)
copyPair.1 += copyPair.1.uppercased()


var copyPair2 = pair
copyPair2.0 += 1
//copyPair.0 = String(copyPair.0) -> Not able to transform the data, would have to create a different pair object, composed by (String, String)
// e.g.:
var convertedCopy: (String, String) = (String(copyPair2.0), copyPair2.1)
convertedCopy.1 += copyPair2.1.uppercased()


// A little more complicate - nested tuple

let nested = ((1, true), "Swift")

nested
    |> first { $0 |> second { !$0 } }

nested
    |> (second >>> first) { !$0 }

// Setter composition composes backwards

//    ✅ This operator is not currently in Swift.
//    ✅ This operator is used in Haskell and PureScript and has a nice shape to it.
//    ✅ It is solving a universal problem, reverse function composition.

precedencegroup BackwardsComposition {
    associativity: left
}
infix operator <<<
func <<< <A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    return { f(g($0)) }
}

nested
    |> (first <<< second) { !$0 }

nested
    |> (first <<< first)(incr)
    |> (first <<< second) { !$0 }
    |> second { $0 + "!" }

let transformation = (first <<< first)(incr)
    <> (first <<< second) { !$0 }
    <> second { $0 + "!" }

nested |> transformation

// If you give me a way of transforming the part of some structure, I will give you a way of transforming the whole of the structure
// ((A) -> B) -> (S) - T

// ((A) -> B) -> ((A) -> C) -> (B, C)
// ((A) -> B) -> ((B) -> C) -> (A, C)

// Arrays
// ((A) -> B) -> ([A]) -> [B]

// Same thing. If you say to transform an element, it can transform it all
func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> ([B]) {
    return { $0.map(f) }
}

(42, ["Swift", "Objective-C"])
    |> (second <<< map) { $0 + "!" }
    |> first(incr)

dump(
[(42, ["Swift", "Objective-C"]), (1729, ["Haskell", "Purescript"])]
    |> (map <<< (second <<< map)) { $0 + "!" }
)

// Plain way

let data = [
  (42, ["Swift", "Objective-C"]),
  (1729, ["Haskell", "PureScript"])
]

data.map { ($0.0, $0.1.map { $0 + "!" }) }

// MARK: - What's the point

/// Is it worth introducing these functions to our code bases?
/// **Answer:** We think so! When they work, they work really well, saving us a lot of boilerplate. When they don’t work, we’re still using the concepts and building intuitions for them. The ideas of currying and flipping are simple, and they’re going to unlock a lot of composition in the future.

//: [Previous](@previous) |
//: [Next](@next)
