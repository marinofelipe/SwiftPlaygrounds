/*:
 # Algebra Data Types
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Point Free - Episode 4- Algebra Data Types Functions](https://www.pointfree.co/episodes/ep4-algebraic-data-types)

 Related to uninhabited types:
 - [Swift Evolution - SE0102 - Remove @noreturn attribute and introduce an empty Never type](https://github.com/apple/swift-evolution/blob/master/proposals/0102-noreturn-bottom-type.md)
*/

/*:
##  Content
*/

struct Pair<A, B> {
  let first: A
  let second: B
}

Pair<Bool, Bool>(first: true, second: true)
Pair<Bool, Bool>(first: true, second: false)
Pair<Bool, Bool>(first: false, second: true)
Pair<Bool, Bool>(first: false, second: false)

enum Three {
  case one
  case two
  case three
}

Pair<Bool, Three>(first: true, second: .one)
Pair<Bool, Three>(first: true, second: .two)
Pair<Bool, Three>(first: true, second: .three)
Pair<Bool, Three>(first: false, second: .one)
Pair<Bool, Three>(first: false, second: .two)
Pair<Bool, Three>(first: false, second: .three)

let _: Void = Void()
let _: Void = ()
let _: () = ()

func foo(_ x: Int) /* -> Void */ {
  // return ()
}

Pair<Bool, Void>.init(first: true, second: ())
Pair<Bool, Void>.init(first: false, second: ())

Pair<Void, Void>.init(first: (), second: ())

__

enum Never {}

//let _: Never = ???

//Pair<Bool, Never>.init(first: true, second: ???)

// Fatal error returns the stdlib type Never
//fatalError()


// Pair<Bool, Bool>  = 4 = 2 * 2
// Pair<Bool, Three> = 6 = 2 * 3
// Pair<Bool, Void>  = 2 = 2 * 1
// Pair<Void, Void>  = 1 = 1 * 1
// Pair<Bool, Never> = 0 = 2 * 0

enum Theme {
  case light
  case dark
}

enum State {
  case highlighted
  case normal
  case selected
}

struct Component {
  let enabled: Bool
  let state: State
  let theme: Theme
}

// 2 * 3 * 2 = 12

// Pair<A, B> = A * B
// Pair<Bool, Bool> = Bool * Bool
// Pair<Bool, Three> = Bool * Three
// Pair<Bool, Void> = Bool * Void
// Pair<Bool, Never> = Bool * Never

// Pair<Bool, String> = Bool * String
// String * [Int]
// [String] * [[Int]]
// Never = 0
// Void = 1
// Bool = 2

enum Either<A, B> {
    case left(A), right(B)
}

Either<Bool, Bool>.left(true)
Either<Bool, Bool>.left(false)
Either<Bool, Bool>.right(true)
Either<Bool, Bool>.right(false)
// Either<Bool, Bool> = 4 = 2 + 2
// 2 + 2

Either<Bool, Three>.left(true)
Either<Bool, Three>.left(false)
Either<Bool, Three>.right(.one)
Either<Bool, Three>.right(.two)
Either<Bool, Three>.right(.three)
// Either<Bool, Three> = 5 = 2 + 3
// 2 + 3

Either<Bool, Void>.left(true)
Either<Bool, Void>.left(false)
Either<Bool, Void>.right(())
// Either<Bool, Void> = 3 = 2 + 1
// 2 + 1

Either<Bool, Never>.left(true)
Either<Bool, Never>.left(false)
//Either<Bool, Never>.right(???)
// Either<Bool, Never> = 2 = 2 + 0
// 2 + 0

// Enums called as sum types

struct Unit: Equatable {}
// type that holds one value

// enum Never
// type that holds no value

let unit = Unit()

//extension Void {}

__

func sum(_ xs: [Int]) -> Int {
    var result: Int = 0
    for x in xs {
        result += x
    }
    return result
}

func product(_ xs: [Int]) -> Int {
    var result: Int = 1
    for x in xs {
        result *= x
    }
    return result
}

let xs = [Int]()
sum(xs)
product(xs)

sum([1, 2]) + sum([3]) == sum([1, 2, 3])
product([1, 2]) * product([3]) == product([1, 2, 3])

sum([1, 2]) + sum([0]) == sum([1, 2, 3])
sum([1, 2]) + 0 == sum([1, 2, 3])
product([1, 2]) * product([0]) == product([1, 2, 3])
product([1, 2]) * 1 == product([1, 2, 3])

// Void = 1
// Void will not change a struct, not hold any info
// A * 1 = A = 1 * A
// Order doesn't matter for the struct, not affected

// Never = 0
// Equivalent to never. Every-time added to a struct it's basically a never.
// A * 0 = 0 = 0 * A

// For enums
// Same as not using the enum
// A + 0 = A = 0 + A

// A + 1 = 1 + A = A?

//Either<A, Void>

//Either<Pair<A, B>, Pair<A, C>>

// A * B + A * C = A * (B + C)

//Pair<A, B, Either<B, C>>


//Pair<Either<A, B>, Either<A, C>>

// (A + B) * (A + C)

import Foundation

//URLSession.shared
//    .dataTask(with: <#T##URL#>, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>)

// (Data + 1) * (URLResponse + 1) * (Error + 1)
//   = Data * URLResponse * Error
//     + Data * URLResponse
//     + URLResponse * Error
//     + Data * Error
//     + Data
//     + URLResponse
//     + Error
//     + 1

// Data * URLResponse + Error

//Either<Pair<Data, URLResponse>, Error> // -> Result<Success, Failure>
//Result<(Data, URLResponse), Error>

// Result that never fails
// Result<Date, Never>

// Result<A, Error>? // optional cause can be cancelled

//: [Previous](@previous) |
//: [Next](@next)
