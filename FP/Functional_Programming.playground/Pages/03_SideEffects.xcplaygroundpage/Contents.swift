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

//: [Previous](@previous) |
//: [Next](@next)
