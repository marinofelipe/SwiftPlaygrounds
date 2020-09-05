// NB: `@_exported` will make foundation available in our playgrounds
@_exported import Foundation

public var __: Void {
  print("--")
}

// MARK: - Operators

precedencegroup ForwardApplication {
  associativity: left
}
infix operator |>: ForwardApplication
public func |> <A, B>(x: A, f: (A) -> B) -> B {
  return f(x)
}

precedencegroup ForwardComposition {
  associativity: left
  higherThan: SingleTypeComposition
}
infix operator >>>: ForwardComposition
public func >>> <A, B, C>(f: @escaping (A) -> B, g: @escaping (B) -> C) -> (A) -> C {
  return { g(f($0)) }
}

precedencegroup SingleTypeComposition {
  associativity: right
  higherThan: ForwardApplication
}
infix operator <>: SingleTypeComposition
public func <> <A>(f: @escaping (A) -> A, g: @escaping (A) -> A) -> (A) -> A {
  return f >>> g
}
public func <> <A>(f: @escaping (inout A) -> Void, g: @escaping (inout A) -> Void) -> (inout A) -> Void {
  return { a in
    f(&a)
    g(&a)
  }
}

public func <> <A: AnyObject>(f: @escaping (A) -> Void, g: @escaping (A) -> Void) -> (A) -> Void {
  return { a in
    f(a)
    g(a)
  }
}

// MARK: - Funcs

// free functions
public func incr(_ x: Int) -> Int {
  return x + 1
}

public func square(_ x: Int) -> Int {
  return x * x
}

// MARK: - High order funcs

public func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in
    { b in
        f(a, b)
    }
  }
}

public func zurry<A>(_ f: () -> A) -> A {
    return f()
}

public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}

// A version of flip with zero arguments

public func flip<A, C>(_ f: @escaping (A) -> () -> C) -> () -> (A) -> C {
  return { { a in f(a)() } }
}

public func |> <A>(a: inout A, f: (inout A) -> Void) -> Void {
    f(&a)
}
