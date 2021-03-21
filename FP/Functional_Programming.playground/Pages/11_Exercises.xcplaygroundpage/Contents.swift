/*:
 # The Many Faces of Map Exercises
 1. Implement a `map` function on dictionary values, i.e.
    ```
    map: ((V) -> W) -> ([K: V]) -> [K: W]
    ```
    Does it satisfy `map(id) == id`?
 */

func map<K, A, B>(_ f: @escaping (A) -> B) -> ([K: A]) -> ([K: B]) {
    return { aDict in
        aDict.mapValues(f)
    }
}

// map(id) == id
// { aDict in
//     aDict.mapValues(f)
// }
// { aDict in
//     aDict.mapValues(f) // if values are mapped to identifier, then it's still aDict
// }
// { aDict in
//     aDict
// }
//{ $0 }

// Does it satisfy `map(id) == id`?
// Yes, sir!

/*:
 2. Implement the following function:
    ```
    transformSet: ((A) -> B) -> (Set<A>) -> Set<B>
    ```
    We do not call this `map` because it turns out to not satisfy the properties of `map` that we saw in this episode. What is it about the `Set` type that makes it subtly different from `Array`, and how does that affect the genericity of the `map` function?
 */

func transformSet<A, B>(_ f: @escaping (A) -> B) -> (Set<A>) -> (Set<B>) {
    return { aSet in
        Set(
            Array(aSet)
                .map(f)
        )
    }
}

// ??

/*:
 3. Recall that one of the most useful properties of `map` is the fact that it distributes over compositions, _i.e._ `map(f >>> g) == map(f) >>> map(g)` for any functions `f` and `g`. Using the `transformSet` function you defined in a previous example, find an example of functions `f` and `g` such that:
    ```
    transformSet(f >>> g) != transformSet(f) >>> transformSet(g)
    ```
    This is why we do not call this function `map`.
 */
// TODO
/*:
 4. There is another way of modeling sets that is different from `Set<A>` in the Swift standard library. It can also be defined as function `(A) -> Bool` that answers the question "is `a: A` contained in the set." Define a type `struct PredicateSet<A>` that wraps this function. Can you define the following?
     ```
     map: ((A) -> B) -> (PredicateSet<A>) -> PredicateSet<B>
     ```
     What goes wrong?
 */
// TODO
/*:
 5. Try flipping the direction of the arrow in the previous exercise. Can you define the following function?
    ```
    fakeMap: ((B) -> A) -> (PredicateSet<A>) -> PredicateSet<B>
    ```
 */
// TODO
/*:
 6. What kind of laws do you think `fakeMap` should satisfy?
 */
// TODO
/*:
 7. Sometimes we deal with types that have multiple type parameters, like `Either` and `Result`. For those types you can have multiple `map`s, one for each generic, and no one version is “more” correct than the other. Instead, you can define a `bimap` function that takes care of transforming both type parameters at once. Do this for `Result` and `Either`.
 */

//func biMap<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
//  return { result in
//    switch result {
//    case let .success(a):
//      return .success(f(a))
//    case let .failure(e):
//      return .failure(e)
//    }
//  }
//}

//: [Previous](@previous)
//: [Next](@next)
