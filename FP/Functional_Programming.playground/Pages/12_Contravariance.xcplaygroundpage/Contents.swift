/*:
 # Contravariance
*/

/*:
## References / Bibliografy

Based on:
 - [Point Free - Episode 14 - Contravariance](https://www.pointfree.co/episodes/ep14-contravariance)
*/

import UIKit

// NSObject > UIResponder > UIView > UIControl > UIButton

// configuration up front, then transformation is curried after
func wrapView(padding: UIEdgeInsets) -> (UIView) -> UIView {
  return { subview in
    let wrapper = UIView()
    subview.translatesAutoresizingMaskIntoConstraints = false
    wrapper.addSubview(subview)
    NSLayoutConstraint.activate([
      subview.leadingAnchor.constraint(
        equalTo: wrapper.leadingAnchor, constant: padding.left
      ),
      subview.rightAnchor.constraint(
        equalTo: wrapper.rightAnchor, constant: -padding.right
      ),
      subview.topAnchor.constraint(
        equalTo: wrapper.topAnchor, constant: padding.top
      ),
      subview.bottomAnchor.constraint(
        equalTo: wrapper.bottomAnchor, constant: -padding.bottom
      ),
      ])
    return wrapper
  }
}

let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .darkGray

let padding = UIEdgeInsets(top: 10, left: 20, bottom: 30, right: 40)

let wrapper = wrapView(padding: padding)(view)
wrapper.frame.size = CGSize(width: 300, height: 300)
wrapper.backgroundColor = .lightGray
wrapper

// able to put more and more specific subclass
wrapView(padding: padding) as (UIView) -> UIView
wrapView(padding: padding) as (UIButton) -> UIView
wrapView(padding: padding) as (UISwitch) -> UIView
wrapView(padding: padding) as (UIStackView) -> UIView

// unable to put a more generic thing, like a parent class

//wrapView(padding: padding) as (UIResponder) -> UIView
//wrapView(padding: padding) as (UIView) -> UIButton

// in the other hand the output is the opposite,
// it doesn't allow a more specific subclass,
// but only a more generic one
wrapView(padding: padding) as (UIView) -> UIResponder
wrapView(padding: padding) as (UIView) -> NSObject
wrapView(padding: padding) as (UIView) -> AnyObject


/*
 If A < B
 then (B -> C) < (A -> C)
 then (C -> A) < (C -> B)

 A: UIButton
 B: UIView
 then (UIView -> NSObject) < (UIButton -> NSObject)
 then (NSObject -> UIButton) < (NSObject -> UIView)
 -------------------------
 If A < B
 then B -> C
        <              contravariant - order of relations ship reversed
      A -> C
 then      C -> A
             <         covariant - order of relations ship preserved
           C -> B

 -------------------------
 Liskov Substitution Principle
 if A < B
 then program with B can be replaced with A without changing its outcome
 */

// order preserved
func map<A, B>(_ f: (A) -> B) -> ([A]) -> [B] {
  fatalError("Unimplemented")
}


struct Func<A, B> {
  let apply: (A) -> B
}


func map<A, B, C>(_ f: @escaping (B) -> C)
  -> ((Func<A, B>) -> Func<A, C>) {
  return { g in
    Func(apply: g.apply >>> f)
  }
}

//func map<A, B, C>(_ f: @escaping (A) -> B)
//  -> ((Func<A, C>) -> Func<B, C>) {
//    return { g in
//      f // (A) -> B
//      g.apply // (A) -> C
//    }
//}

// flips the order of elements
func contramap<A, B, C>(_ f: @escaping (B) -> A)
  -> ((Func<A, C>) -> Func<B, C>) {
    return { g in
//      f // (B) -> A
//      g.apply // (A) -> C
//      Func(apply: f >>> g.apply)
      Func(apply: g.apply <<< f)
    }
}


struct F3<A> {
  let run: (@escaping (A) -> Void) -> Void
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
  return { f3 in
    return F3 { callback in
      f3.run(f >>> callback)
    }
  }
}

// (A) -> B
//  -1    +1
// ((A) -> Void) -> Void
//  |_|    |___|
//   -1      +1
// |___________|    |___|
//      -1           +1
// A = +1

// (A) -> ((B) -> C) -> D)
//         |_|   |_|
//          -1    +1
//         |_______|   |_|
//            -1        +1
// |_|    |______________|
//  -1           +1
// A = -1 // contravariant
// B = +1 // covariant
// C = -1 // contravariant
// D = +1 // covariant

// Set<A: Hashable, Equatable>
let xs = Set<Int>([1, 2, 3, 4, 4, 4, 4])

xs.forEach { print($0) }

struct PredicateSet<A> {
  let contains: (A) -> Bool

  func contramap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
    return PredicateSet<B>(contains: f >>> self.contains)
  }
}

let ys = PredicateSet { [1, 2, 3, 4].contains($0) }

let evens = PredicateSet { $0 % 2 == 0 }
let odds = evens.contramap { $0 + 1 }
evens.contains(1)
odds.contains(1)

let allInts = PredicateSet<Int> { _ in true }
let longStrings = PredicateSet<String> { $0.count > 100 }

let allIntsNot1234 = PredicateSet { !ys.contains($0) }
allIntsNot1234.contains(5)
allIntsNot1234.contains(4)

let isLessThan10 = PredicateSet<Int> { $0 < 10 }

struct User {
  let id: Int
  let name: String
}

let usersWithIdLessThan10 = isLessThan10.contramap(\User.id)
usersWithIdLessThan10.contains(User(id: 100, name: "Blob"))

let usersWithShortNames = isLessThan10.contramap(\User.name.count)
usersWithShortNames.contains(User(id: 1, name: "Blob Blob Blob"))


// No fully generic map. Destroy genericity by explicitly constraining to Hashable

// Map on Set doesn't make sense if we were to have the same patterns and intuitions that other maps have
func map<A: Hashable, B: Hashable>(
  _ f: @escaping (A) -> B
) -> (Set<A>) -> Set<B> {

  return { xs in
    var ys = Set<B>()
    for x in xs {
      ys.insert(f(x))
    }
    return ys
  }
}

let zs: Set<Int> = [-1, 0, 1]
zs
  |> map(square)

// map(f >>> g) == map(f) >>> map(g)
struct Trivial<A>: Hashable {
  let value: A

  static func == (lhs: Trivial, rhs: Trivial) -> Bool {
    return true
  }

  var hashValue: Int {
    return 1
  }
}

zs
  |> map(Trivial.init >>> \.value)

zs
  |> map(Trivial.init)
  |> map(\.value)

zs.map(Trivial.init >>> \.value)
zs.map(Trivial.init).map(\.value)

//: [Previous](@previous)
//: [Next](@next)
