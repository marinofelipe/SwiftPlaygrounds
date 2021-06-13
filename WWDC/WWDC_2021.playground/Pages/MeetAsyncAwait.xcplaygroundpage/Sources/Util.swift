import Foundation
import SwiftUI

public struct Cover: View {
    let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var body: some View {
        HStack {
            Text(name)
        }
    }
}

public struct TitleText: View {
    let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var body: some View {
        HStack {
            Text(name)
        }
    }
}

public struct AuthorText: View {
    let name: String

    public init(_ name: String) {
        self.name = name
    }

    public var body: some View {
        HStack {
            Text(name)
        }
    }
}

public struct RingProgressView: View {
    let value: Float

    public init(value: Float) {
        self.value = value
    }

    public var body: some View {
        HStack {
            Text("\(value)")
        }
    }
}

/// Mimics TextEditor while this Playground does not run on Xcode12
public struct TextEditor: View {
    @Binding var note: String

    public init(_ note: Binding<String>) {
        self._note = note
    }

    public var body: some View {
        HStack {
            Text("\(note)")
        }
    }
}
