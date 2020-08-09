import XCTest

@discardableResult
public func assertEqual<A: Equatable>(_ lhs: A, _ rhs: A) -> String {
  return lhs == rhs ? "✅" : "❌"
}

@discardableResult
public func assertEqual<A: Equatable, B: Equatable>(_ lhs: (A, B), _ rhs: (A, B)) -> String {
  return lhs == rhs ? "✅" : "❌"
}

precedencegroup ForwardApplication {
  associativity: left
}
infix operator |>: ForwardApplication
public func |> <A, B>(x: A, f: (A) -> B) -> B {
  return f(x)
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: ForwardApplication
}
infix operator >>>: ForwardComposition
public func >>> <A, B, C>(
  f: @escaping (A) -> B,
  g: @escaping (B) -> C
  ) -> ((A) -> C) {

  return { g(f($0)) }
}

public func incr(_ x: Int) -> Int {
  return x + 1
}

public func square(_ x: Int) -> Int {
  return x * x
}
