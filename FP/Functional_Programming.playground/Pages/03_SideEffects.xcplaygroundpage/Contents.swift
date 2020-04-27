/*:
 # Side Effects

TODO: Description

 > TODO: if any
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Point Free - Episode 2 - Side Effects](https://www.pointfree.co/episodes/ep2-side-effects)
*/

/*:
##  Learnings and Thoughts

 TODO:
*/

/*:
##  Freeplay

*/

// Free functions

// Without side effects
func compute(_ x: Int) -> Int {
    x * x + 1
}

compute(2)
compute(2)
compute(2)

assertEqual(5, compute(2)) // present on Utils.swift
assertEqual(6, compute(2))
assertEqual(5, compute(3))

// With side effects
func computeWithSideEffect(_ x: Int) -> Int {
    let computation = x * x + 1
    print("Computed \(computation)")

    return computation
}

assertEqual(5, computeWithSideEffect(2))
// No way to test if print is being executed correctly

// Both have the same result
[2, 10].map(compute).map(compute)
[2, 10].map(compute >>> compute)

// which not happens with effects
[2, 10].map(computeWithSideEffect).map(computeWithSideEffect)
__
[2, 10].map(computeWithSideEffect >>> computeWithSideEffect)

// How to remove the side effect and return it
func computeAndPrint(_ x: Int) -> (Int, [String]) {
    let computation = x * x + 1
    return(computation, ["Computed \(computation)"])
}

__
computeAndPrint(2)

assertEqual(
    computeAndPrint(2),
    (5, ["Computed 5"])
)
assertEqual(
    computeAndPrint(3),
    (5, ["Computed 5"])
)
assertEqual(
    computeAndPrint(2),
    (5, ["Computed 6"])
)
assertEqual(
    computeAndPrint(2),
    (6, ["Computed 5"])
)

// By moving the side effect to the caller, the functions are maintained pure,
// and the side effect can be done on the boundary.
let (computation, logs) = computeAndPrint(2)
__
logs.forEach { print($0) }

// Getting back to function composition
2 |> compute >>> compute
2 |> computeWithSideEffect >>> computeWithSideEffect

// It does not work with computeAndPrint at the moment because it returns a tuple
//2 |> computeAndPrint >>> computeAndPrint

// Solving it
func compose<A, B, C>(
    _ f: @escaping (A) -> (B, [String]),
    _ g: @escaping (B) -> (C, [String])
) -> ((A) -> (C, [String])) {
    return { a in
        let (b, logs) = f(a)
        let (c, moreLogs) = g(b)

        return (c, logs + moreLogs)
    }
}

2 |> compose(computeAndPrint, computeAndPrint)
2 |> compose(compose(computeAndPrint, computeAndPrint), computeAndPrint)

// Does not read well - Infix operator for the rescue

precedencegroup EffectfulComposition {
    associativity: left
    higherThan: ForwardApplication
    lowerThan: ForwardComposition
}

// fish operator
infix operator >=>: EffectfulComposition

func >=><A, B, C>(
    _ f: @escaping (A) -> (B, [String]),
    _ g: @escaping (B) -> (C, [String])
) -> ((A) -> (C, [String])) {
    return { a in
        let (b, logs) = f(a)
        let (c, moreLogs) = g(b)

        return (c, logs + moreLogs)
    }
}

2
    |> computeAndPrint
    >=> incr
    >>> computeAndPrint
    >=> square
    >>> computeAndPrint

/*
Questions to validate a new functional operator:
1. Does it not already exist in Swift?
2. Does this operator has a lot of priority?
3. Does it solve an universal problem or a domain specific problem?
*/

// Yes for all, and for its universality:

// Can be used to deal with chain of optionals without the need to unwrap
func >=><A, B, C>(
    _ f: @escaping (A) -> B?,
    _ g: @escaping (B) -> C?
) -> ((A) -> C?) {
    return { a in
        guard let b = f(a) else { return nil }
        return g(b) // goes to C
    }
}

String.init(utf8String:) >=> URL.init(string:)

// Can be used to convert to array
func >=><A, B, C>(
    _ f: @escaping (A) -> [B],
    _ g: @escaping (B) -> [C]
) -> ((A) -> [C]) { 
    return { a in
        let arrayOfB = f(a)
        return arrayOfB.flatMap(g) // let arrayOfC
    }
}

__

// More complex side effect

func greetWithEffect(_ name: String) -> String {
    let seconds = Int(Date().timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(seconds) seconds past minute."
}

greetWithEffect("Mark")

// Lack of control over date
assertEqual(
    "Hello Mark! It's 19 seconds past minute.",
    greetWithEffect("Mark")
)

// By parameter injecting Date
func greet(at date: Date = .init(), name: String) -> String {
    let seconds = Int(date.timeIntervalSince1970) % 60
    return "Hello \(name)! It's \(seconds) seconds past minute."
}

// Recovers testability and control
assertEqual(
    "Hello Mark! It's 19 seconds past minute.",
    greet(at: Date(timeIntervalSince1970: 19), name: "Mark")
)

// But it broke composition
func uppercased(_ string: String) -> String {
    string.uppercased()
}

uppercased

"Mark" |> uppercased >>> greetWithEffect
"Mark" |> greetWithEffect >>> uppercased

//"Mark" |> uppercased >>> greet
//"Mark" |> greet >>> uppercased

greet

func greet(at date: Date) -> (String) -> String {
    return { name in
        let seconds = Int(date.timeIntervalSince1970) % 60
        return "Hello \(name)! It's \(seconds) seconds past minute."
    }
}

greet(at: Date()) >>> uppercased
uppercased >>> greet(at: Date())
"Mark" |> greet(at: Date()) >>> uppercased
"Mark" |> uppercased >>> greet(at: Date())

assertEqual(
    "Hello MARK! It's 40 seconds past minute.",
    "Mark" |> uppercased >>> greet(at: Date(timeIntervalSince1970: 40))
)

// MARK: - Mutations

let numberFormatter = NumberFormatter()

func decimalStyle(_ format: NumberFormatter) {
    format.numberStyle = .decimal
    format.maximumFractionDigits = 2
}

func currencyStyle(_ format: NumberFormatter) {
    format.numberStyle = .currency
    format.roundingMode = .down
}

func wholeStyle(_ format: NumberFormatter) {
    format.maximumFractionDigits = 0
}

decimalStyle(numberFormatter)
wholeStyle(numberFormatter)
numberFormatter.string(from: 1234.6)

currencyStyle(numberFormatter)
numberFormatter.string(from: 1234.6)

wholeStyle(numberFormatter)
numberFormatter.string(from: 1234.6)

// 1. fixing with value types - copy to the rescue

// Wrapper around number formatter config
struct NumberFormatterConfig {
    var numberStyle: NumberFormatter.Style = .none
    var roundingMode: NumberFormatter.RoundingMode = .up
    var maximumFractionDigits: Int = 0

    var formatter: NumberFormatter {
        let result = NumberFormatter()
        result.numberStyle = self.numberStyle
        result.roundingMode = self.roundingMode
        result.maximumFractionDigits = self.maximumFractionDigits
        return result
    }
}

func decimalStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
    var format = format
    format.numberStyle = .decimal
    format.maximumFractionDigits = 2
    return format
}

func currencyStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
    var format = format
    format.numberStyle = .currency
    format.roundingMode = .down
    return format
}

decimalStyle >>> currencyStyle

func wholeStyle(_ format: NumberFormatterConfig) -> NumberFormatterConfig {
    var format = format
    format.maximumFractionDigits = 0
    return format
}

wholeStyle(decimalStyle(NumberFormatterConfig()))
    .formatter
    .string(from: 1234.6)

currencyStyle(NumberFormatterConfig())
    .formatter
    .string(from: 1234.6)

wholeStyle(decimalStyle(NumberFormatterConfig()))
    .formatter
    .string(from: 1234.6)

// 2. fixing with reference types? NOOOOOOO!

// No guarantees by the compiler
// Internally we can still mutate it and the caller will never know that the same instance is being returned (which is the original problem of mutation and the side-effects they can have that was initially presented)

func decimalStyle2(_ format: NumberFormatter) -> NumberFormatter {
    let format = format.copy() as! NumberFormatter
    format.numberStyle = .decimal
    format.maximumFractionDigits = 2
    return format
}

// 3. Doing the same as first done with references, but using inout/mutable value type parameters
// Swift compiler amazingly let's us know that we need to pass a mutable value that will be mutated
// Same initial problem appears. But now it's clear by the compiler that a lot of mutating is happening and this might be causing the problems.
// Lesson, value types are amazing for mutation!
// Bad here, with inout we cannot rely on functions composition.

func inoutDecimalStyle(_ format: inout NumberFormatterConfig) {
    format.numberStyle = .decimal
    format.maximumFractionDigits = 2
}

func inoutCurrencyStyle(_ format: inout NumberFormatterConfig) {
    format.numberStyle = .currency
    format.roundingMode = .down
}

func inoutWholeStyle(_ format: inout NumberFormatterConfig) {
    format.maximumFractionDigits = 0
}

var config = NumberFormatterConfig()

inoutDecimalStyle(&config)
inoutWholeStyle(&config)
config.formatter.string(from: 1234.6)

inoutCurrencyStyle(&config)
config.formatter.string(from: 1234.6)

inoutDecimalStyle(&config)
inoutWholeStyle(&config)
config.formatter.string(from: 1234.6)

// 4. Another way

func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { a in
        a = f(a)
    }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var a = a
        f(&a)
        return a
    }
}

precedencegroup SingleTypeComposition {
    associativity: left
    higherThan: ForwardApplication
}

// diamond operator
infix operator <>: SingleTypeComposition

// Why not use only forward composition? Because with this operator we make clear that this composes from A to A. It's constrained and clear.
func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
    f >>> g
}

func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
    return { a in
        f(&a)
        g(&a)
    }
}

func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
    f(&a)
}

config |> decimalStyle <> currencyStyle
config |> inoutDecimalStyle <> inoutCurrencyStyle

/* EXERCISES */
/// 1. Implement `effectful composition >=>` for optionals and array ✅

//: [Previous](@previous) |
//: [Next](@next)
