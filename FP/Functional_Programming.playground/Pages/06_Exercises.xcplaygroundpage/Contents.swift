/*:
 # Higher Order Functions - Exercises
*/

/*:
## References / Bibliografy

This short article explains how everything can be seen to be a function, even values and function application. Eitan coins the term zurry to describe the act of currying a zero-argument function.
 - [Everything’s a Function](https://tangledw3b.wordpress.com/2013/01/18/cartesian-closed-categories/)
*/

/*:
 1. Write curry for functions that take 3 arguments.
*/

func curry<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> (D) {
    return { a in
        { b in
            { c in
                f(a, b, c)
            }
        }
    }
}

String.init(format:locale:arguments:)
flip(curry(String.init(format:locale:arguments:)))

/*:
 2. Explore functions and methods in the Swift standard library, Foundation, and other third party code, and convert them to free functions that compose using curry, zurry, flip, or by hand.
*/

func compactMap<A, B>(_ f: @escaping (A?) -> B?) -> ([A?]) -> ([B]) {
    return { $0.compactMap(f) }
}

let names = ["Báh", "Fe", nil, "Diego", "Ronaldo"]
    |>
    filter { $0?.count ?? 0 <= 5 }
    >>>
    compactMap { $0 }
names

/*:
 3. Explore the associativity of function arrow ->. Is it fully associative, i.e. is ((A) -> B) -> C equivalent to (A) -> ((B) -> C), or does it associate to only one side? Where does it parenthesize as you build deeper, curried functions?
*/

//func equivalence<A, B, C>(
//    _ f: @escaping (A) -> ((B) -> C)
//) -> ((A) -> B) -> C {
//    return { a in
//        { b in
//            f(a)(b)
//        }
        // How to return something in C in here???
//    }
//}

/// It turns out, the function arrow -> only associates to the right. So if we were to write:
/// f: (A) -> (B) -> (C) -> D
/// what that really means is:
/// f: (A) -> ((B) -> ((C) -> D))


/*:
 4. Write a function, uncurry, that takes a curried function and returns a function that takes two arguments. When might it be useful to un-curry a function?
*/

func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> (C)) -> (A, B) -> (C) {
    return { a, b in
        f(a)(b)
    }
}

String.init(format:locale:arguments:)
let stringWithLocale = flip(curry(String.init(format:locale:arguments:)))
let englishLocaleString = stringWithLocale(Locale(identifier: "en"))

uncurry(stringWithLocale)
uncurry(flip(stringWithLocale)) // Flips the curried version, back to (String, Locale), then uncury it. It gets equal the original func = String.init(format:locale:arguments:)
flip(uncurry(stringWithLocale)) // Flips the uncurried version - That's why it is a function that goes from (A) -> (B,C)
uncurry(curry(String.init(format:locale:arguments:)))

/// > When might it be useful to un-curry a function?
/// Potentially when wanting to provide an API that has arguments within the same function, to make it easier for the users.
/// Or to transform a curried function into a tuple.

 /*:
 5. Write reduce as a curried, free function. What is the configuration vs. the data?
 */

[1, 2].reduce(0, { $0 + $1 })
[1, 2].reduce(0, +)

// Swift.Collection
//func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Self.Element) throws -> Result) rethrows -> Result

//The reduce method on collections takes two arguments: the initial value to reduce into, and the accumulation function that takes what has been accumulated so far and a value from the array and must return a new accumulation value. The accumulation function is most like configuration in that it describes how to perform the reduce, and is most likely to be reused across many reduces. Whereas the initial value, and the collection being operated on, are like the data since it’s what you aren’t likely to have access to until the moment you want to reduce. So a possible curried signature of reduce might take the accumulation upfront, and delay the initial value and collection:
func reduce<A, R>(
  _ accumulator: @escaping (R, A) -> R
) -> (R) -> ([A]) -> R {
  return { initialValue in
    return { collection in
      return collection.reduce(initialValue, accumulator)
    }
  }
}

 /*:
 6. In programming languages that lack sum/enum types one is tempted to approximate them with pairs of optionals. Do this by defining a type struct PseudoEither<A, B> of a pair of optionals, and prevent the creation of invalid values by providing initializers.
 This is “type safe” in the sense that you are not allowed to construct invalid values, but not “type safe” in the sense that the compiler is proving it to you. You must prove it to yourself.
 */

struct PseudoEither<A, B> {
    let optionalA: A?
    let optionalB: B?

    init(optionalA: A) {
        self.optionalA = optionalA
        self.optionalB = nil
    }

    init(optionalB: B) {
        self.optionalA = nil
        self.optionalB = optionalB
    }
}

 /*:
 7. Explore how the free map function composes with itself in order to transform a nested array. More specifically, if you have a doubly nested array [[A]], then map could mean either the transformation on the inner array or the outer array. Can you make sense of doing map >>> map?
 */

func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> ([B]) {
    return { $0.map(f) }
}

[1, 2, 3, 4]
    |> map { "\($0)" }

//[[1, 2, 3, 4]]
//    |> map >>> map

//func flatMap<ElementOfResult>(_ transform: (Element) throws -> ElementOfResult?) rethrows -> [ElementOfResult]

map(incr) >>> map(incr)

//: [Previous](@previous) |
//: [Next](@next)
