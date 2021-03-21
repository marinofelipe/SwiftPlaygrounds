/*:
 # The Many Faces of Map
*/

/*:
## References / Bibliografy

Based on:
 - [Point Free - Episode 13 - The Many Faces of Map](https://www.pointfree.co/episodes/ep13-the-many-faces-of-map)
*/

// MARK: - Map - transform Sequence elements

[1, 2, 3]
  .map { $0 + 1 }

[1, 2, 3]
  .map(incr)

// MARK: - Free map - Composes lil nicer

[1, 2, 3]
  |> map(incr)
[1, 2, 3]
  |> map(incr)
  |> map(square)

// MARK: - Std map on Optional

Int?.some(2)
  .map(incr)
Int?.none
  .map(incr)

// MARK: - Free map on Optional

Int?.some(2)
  |> map(incr)
Int?.some(2)
  |> map(incr)
  |> map(square)
Int?.some(2)
  |> map(incr >>> square)

// MARK: - Transformation that doesn't do anything

let optionalInts: [Int] = [1, 2, 3]

optionalInts
  .compactMap { $0 }

Int?.some(2)
  .map { $0 }

// Identity function - "does nothing but return its argument"
// A bit more performant since it can be used without the anonymous function
func identity<A>(_ a: A) -> A {
  return a
}

optionalInts
  .compactMap(identity)

Int?.some(2)
  .map(identity)

[1, 2, 3].map(identity) == identity([1, 2, 3]) // true
Int?.some(2).map(identity) == identity(Int?.some(2)) // true
// f >>> id = f
// id >>> f = f

// MARK: - Lift

func lift<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
  return { xs in
//    return []
//    return (xs + xs).map(f)
//    return (xs + xs + xs).map(f)
//    return xs.reversed().map(f)
    return Array(xs.prefix(1)).map(f)
    return Array(xs.prefix(2)).map(f)
    return Array(xs.suffix(1)).map(f)
    return Array(xs.suffix(2)).map(f)

    return (xs.map(f) + xs.map(f))
    return (xs.map(f) + xs.map(f) + xs.map(f))
    return xs.map(f).reversed()
    return Array(xs.map(f).prefix(1))
    return Array(xs.map(f).prefix(2))
    return Array(xs.map(f).suffix(1))
    return Array(xs.map(f).suffix(2))
  }
}

// if f, g are functions
// lift(f) >>> map(g) == map(f) >>> lift(g)
let xs = [1, 2, 3, 4]
let f = incr
let g = { (x: Int) in String(x) }

let lhs = lift(f) >>> map(g)
let rhs = map(f) >>> lift(g)

lhs(xs)
rhs(xs)
lhs(xs) == rhs(xs)

// Suppose lift(id) = id
// If f = id, g is any function
// lift(id) >>> map(g) == map(id) >>> lift(g)
// id >>> map(g) == id >>> lift(g)
// map(g) == lift(g)

func r<A>(_ xs: [A]) -> A? {
  fatalError()
}

enum Result<A, E> {
  case success(A)
  case failure(E)
}


func map<A, B, E>(_ f: @escaping (A) -> B) -> (Result<A, E>) -> Result<B, E> {
  return { result in
    switch result {
    case let .success(a):
      return .success(f(a))
    case let .failure(e):
      return .failure(e)
    }
  }
}

Result<Int, String>.success(42)
  |> map(incr)
Result<Int, String>.failure("Error")
  |> map(incr)


struct F1<A> {
  let value: A
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F1<A>) -> F1<B> {
  return { f1 in
    F1(value: f(f1.value))
  }
}

// map(id) == id
//return { f1 in
//  F1(value: id(f1.value))
//}
//return { f1 in
//  F1(value: f1.value)
//}
//return { f1 in
//  f1
//}
//return { $0 }

struct F2<A, B> {
  let apply: (A) -> B
}


func map<A, B, C>(_ f: @escaping (B) -> C) -> (F2<A, B>) -> F2<A, C> {
  return { f2 in
//    return F2 { a in
//      f(f2.apply(a))
//    }
    return F2(apply: f2.apply >>> f)
  }
}

// map(id) == id
//{ f2 in
//  return F2(apply: f2.apply >>> id)
//}
//{ f2 in
//  return F2(apply: f2.apply)
//}
//{ f2 in
//  return f2
//}
//{ $0 }

struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}


//URLSession.shared.dataTask(with: URL, completionHandler: <#T##(Data?, URLResponse?, Error?) -> Void#>) -> Void
func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
  return { f3 in
    F3 { callback in
//      f3.run // ((A) -> Void) -> Void
//      callback // (B) -> Void
//      f // (A) -> B
//      f >>> callback // (A) -> Void
      f3.run(f >>> callback)
    }
  }
}

// map(id) == id
//return { f3 in
//  F3 { callback in
//    f3.run(id >>> callback)
//  }
//}
//return { f3 in
//  F3 { callback in
//    f3.run(callback)
//  }
//}
//return { f3 in
//  F3(run: f3.run)
//}
//return { f3 in
//  f3
//}
//return { $0 }

// func map   <A, B>(_ f: (A) -> B) -> (F1   <A>) -> F1   <B>
// func map<R, A, B>(_ f: (A) -> B) -> (F2<R, A>) -> F2<R, B>
// func map   <A, B>(_ f: (A) -> B) -> (F3   <A>) -> F3   <B>

//: [Previous](@previous)
//: [Next](@next)
