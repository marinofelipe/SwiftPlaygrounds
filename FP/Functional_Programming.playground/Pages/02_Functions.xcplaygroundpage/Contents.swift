/*:
 # Functions

TODO: Description

 > TODO: if any
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Point Free - Episode 1 - Functions](https://www.pointfree.co/episodes/ep1-functions)
*/

/*:
##  Learnings and Thoughts

 TODO:
*/

/*:
##  Freeplay

*/

// free functions
func incr(_ x: Int) -> Int {
  return x + 1
}

incr(2)

func square(_ x: Int) -> Int {
  return x * x
}

square(incr(2))

// Extending Int
extension Int {
  func incr() -> Int {
    return self + 1
  }

  func square() -> Int {
    return self * self
  }
}

2.incr()
2.incr().square()

// Custom operators
infix operator |> // called the pipe forward operator - used in F#, Elm, others

func |> <A, B>(a: A, f: (A) -> B) -> B {
    f(a)
}

2 |> incr
//2 |> incr |> square // ⚠️ Adjacent operators are in non-associative precedence group 'DefaultPrecedence'.
(2 |> incr) |> square // here a precedence group is added, which in this case is not the best way of dealing with this. e.g. With tons of adjacent operators, there would be even more parenthesis.

// Precedence group
precedencegroup ForwardApplication {
    associativity: left
}

infix operator ||>: ForwardApplication // for the sake of the readability of the playground, the operator is redefined with an additional `|`, to be used both without and with a custom "precedencegroup".

func ||> <A, B>(a: A, f: (A) -> B) -> B {
    f(a)
}

2 ||> incr
2 ||> incr ||> square // ✅ It works correctly with the custom "precedencegroup" defined to left.

// Function composition
infix operator >>> // Forward compose operator

func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

incr >>> square
let sqrAndIncr = square >>> incr

(incr >>> square)(2)
sqrAndIncr(2)

// Function composition with correct precedence group
precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>>: ForwardComposition // forward compose operator with additional `>` to exemplify conformance to ForwardComposition

func >>>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
    return { a in
        g(f(a))
    }
}

2 ||> incr >>>> square

// The same without function composition
// Not generic + much less reusable + Boiler plate
// + noise + the composed functions hidden + more lines of code
extension Int {
    func incrAndSquare() -> Int {
        self.incr().square()
    }
}

2.incrAndSquare()

// Going even further

/* Because initializers are actually functions, we can use them when composing functions,
 to generate outputs of different types */
2 ||> incr >>>> square >>>> String.init >>>> Double.init

// the same on `method world` - only wrapping it
Double(String(2.incrAndSquare()))

// Using API's that expect free functions - as there are a bunch in Swift API design
[1, 2, 3]
    .map(incr)
    .map(square)

[1, 2, 3]
    .map(incr >>>> square)

// The $0 is the point. The data that is transforming.
// "To program in the point free style, you never refer to the data you are transforming.
// You entirely focus on functions and composition.

// Problem: Free functions and lack of control - This is going to be explored later on the series.

/*
Questions to validate a new functional operator:
1. Does it not already exist in Swift?
2. Does this operator has a lot of priority?
3. Does it solve an universal problem or a domain specific problem?
*/

//: [Previous](@previous) |
//: [Next](@next)
