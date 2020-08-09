func flip<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (B) -> (A) -> C {
  return { b in { a in f(a)(b) } }
}

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
  return { a in
    { b in
        f(a, b)
    }
  }
}

func zurry<A>(_ f: () -> A) -> A {
    return f()
}
