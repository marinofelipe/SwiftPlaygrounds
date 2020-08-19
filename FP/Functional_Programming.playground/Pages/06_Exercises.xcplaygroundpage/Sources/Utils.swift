public func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}

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

public func filter<A>(_ p: @escaping (A) -> Bool) -> ([A]) -> ([A]) {
    return { $0.filter(p) }
}
