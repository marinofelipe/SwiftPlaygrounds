/*:
 # Algebraic Data Types Exercises

 1. What algebraic operation does the function type `(A) -> B` correspond to? Try explicitly enumerating all the values of some small cases like `(Bool) -> Bool`, `(Unit) -> Bool`, `(Bool) -> Three` and `(Three) -> Bool` to get some intuition.
 */
// (Bool) -> Bool
// (false) -> true
// (false) -> false
// (true) -> true
// (true) -> false
// = 4 = 2 * 2 = Bool * Bool
// Is multiplication the answer??

__
// (Unit) -> Bool
// (1) -> true
// (1) -> false
// = 2 = 1 * 2 = Unit * Bool
// Again... this looks like multiplication...

__
// (Bool) -> Three
// (false) -> .one
// (false) -> .two
// (false) -> .three
// (true) -> .one
// (true) -> .two
// (true) -> .three
// = 6 = 2 * 3 = Bool * Three
// Now I'm sure, this is multiplication

// Okay, this means every time in Swift we use a `map` the compiler has two deal with A * B possibilities, right??
/*:
 2. Consider the following recursively defined data structure. Translate this type into an algebraic equation relating `List<A>` to `A`.
 */
indirect enum List<A> {
  case empty
  case cons(A, List<A>)
}

// PS: Indirect enums are used to tell Swift that this is a recursive,
// so Swift can better store them making sure they are no infinitely recursive

__

// TODO
/*:
 3. Is `Optional<Either<A, B>>` equivalent to `Either<Optional<A>, Optional<B>>`? If not, what additional values does one type have that the other doesn’t?
 */
// Optional<Either<A, B>>
// .none = + 1
// A + B
// Bool, Bool
// A.false
// A.true
// B.false
// B.true
// 2 + 2 // +1, since (Optional)
// = 5

__

// Either<Optional<A>, Optional<B>>
// A + B
// Bool?, Bool?
// A.false
// A.true
// A.none
// B.false
// B.true
// B. none
// 3 + 3
// = 6

__

// Answer: They are not equivalent. One have .none and the other can be either .none for A or .none for B.
/*:
 4. Is `Either<Optional<A>, B>` equivalent to `Optional<Either<A, B>>`?
 */
// Either<Optional<A>, B>
// A + B
// Bool?, Three
// false, _
// true, _
// .none,
// _, .one
// _, .two
// _, .three
// 3 + 3
// = 6

// PS: Either is kind of sum

__

// Optional<Either<A, B>>
// .none // + 1
// Bool, Three
// false, _
// true, _
// _, .one
// _, .two
// _, .three
// 2 + 3 // + 1 (Optional)
// = 6

// Answer: In parts yes. In algebraic they are both sum that results in 6, but in the Swift world they
// generate different results, since one would contain a nil and the other be nil.
// It can be considered a yes since for both cases they will be equivalent to nil and also can result
// in all other combinations of A + B.
/*:
 5. Swift allows you to pass types, like `A.self`, to functions that take arguments of `A.Type`. Overload the `*` and `+` infix operators with functions that take any type and build up an algebraic representation using `Pair` and `Either`. Explore how the precedence rules of both operators manifest themselves in the resulting types.
 */
//infix operator *
func *<A: Any, B: Any>(_ a: A.Type, b: B.Type) {
    let pair: Pair<A.Type, B.Type> = Pair(first: a, second: b)
    debugPrint(pair.first)
    debugPrint(pair.second)
}

//infix operator +
func +<A: Any, B: Any>(_ a: A.Type, b: B.Type) {
    let either: Either<A.Type, B.Type>
    // 
}
