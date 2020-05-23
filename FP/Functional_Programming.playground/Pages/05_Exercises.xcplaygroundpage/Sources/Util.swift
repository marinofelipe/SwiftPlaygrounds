public struct Pair<A, B> {
    public let first: A
    public let second: B

    public init(first: A, second: B) {
        self.first = first
        self.second = second
    }
}

public enum Three {
    case one
    case two
    case three
}

public enum Never {}

public enum Theme {
    case light
    case dark
}

public enum State {
    case highlighted
    case normal
    case selected
}

public struct Component {
    public let enabled: Bool
    public let state: State
    public let theme: Theme
}

public enum Either<A, B> {
    case left(A), right(B)
}

public struct Unit: Equatable {}

public var __: Void {
    print("--")
}
