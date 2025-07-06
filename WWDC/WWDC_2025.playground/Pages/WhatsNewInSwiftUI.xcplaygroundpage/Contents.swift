import Foundation

/*:
 # What's new in SwiftUI

 [WWDC video](https://developer.apple.com/videos/play/wwdc2025/256)
*/

/*:
## Key Points
- Liquid ass, the new Design System
 - bottom-aligned search 🙏
 - on iOS tab-based apps, search appears at trailing bottom and morphs with the tab bar items
 - APIs for custom views
- iPad windows are fully resizable
  - Dynamic content is more important than ever
- Capabilities
  - SwiftUI instruments
  - Drastically improved List performance
  - Same for scroll performance
  - Nested Lazy layouts
  - Animatable macro
  - New depth-based variations of animation/alignment modifiers
- SwiftUI <> AppKit improvements
- WebView/WebPage in SwiftUI
- 3D charts
- Rich text editing
 - Attributed String in text inputs
*/

// MARK: - iOS bottom-aligned search-bar

// SwiftUI

import SwiftUI

struct HealthTabView: View {
  @State private var text: String = ""

  var body: some View {
    TabView {
      Tab("Summary", systemImage: "heart") {
        NavigationStack {
          Text("Summary")
        }
      }
      Tab("Sharing", systemImage: "person.2") {
        NavigationStack {
          Text("Sharing")
        }
      }
      Tab(role: .search) { // search role as tab item
        NavigationStack {
          Text("Search")
        }
      }
    }
    .searchable(text: $text)
  }
}

// MARK: - Glass effect

struct ToTopButton: View {
  var body: some View {
    Button("To Top", systemImage: "chevron.up") {
      scrollToTop()
    }
    .padding()
    .glassEffect()
  }

  func scrollToTop() {
    // Scroll to top of view
  }
}

// MARK: - Animatable Macro

@Animatable
struct LoadingArc: Shape {
  var center: CGPoint
  var radius: CGFloat
  var startAngle: Angle
  var endAngle: Angle
  @AnimatableIgnored var drawPathClockwise: Bool

  func path(in rect: CGRect) -> Path {
    // Creates a `Path` arc using properties
    return Path()
  }
}

// MARK: - Web View

import WebKit

struct InAppBrowser: View {
  @State private var page = WebPage()

  var body: some View {
    WebView(page)
      .ignoresSafeArea()
      .onAppear {
        page.load(URLRequest(url: sunshineMountainURL))
      }
  }

  var sunshineMountainURL: URL {
    URL(string: "sunshineMountainURL")!
  }
}

// MARK: - macOS drag and drop

struct DragDropExample: View {
  @State private var selectedPhotos: [Photo.ID] = []
  var body: some View {
    ScrollView {
      LazyVGrid(columns: gridColumns) {
        ForEach(model.photos) { photo in
          view(photo: photo)
            .draggable(containerItemID: photo.id)
        }
      }
    }
    .dragContainer(for: Photo.self, selection: selectedPhotos) { draggedIDs in
      photos(ids: draggedIDs)
    }
    .dragConfiguration(DragConfiguration(allowMove: false, allowDelete: true))
    .onDragSessionUpdated { session in
      let ids = session.draggedItemIDs(for: Photo.ID.self)
      if session.phase == .ended(.delete) {
        trash(ids)
        deletePhotos(ids)
      }
    }
    .dragPreviewsFormation(.stack)
  }
}

// MARK: - Rich text view

struct CommentEditor: View {
  @Binding var commentText: AttributedString

  var body: some View {
    TextEditor(text: $commentText)
  }
}

//: [Previous](@previous) |
//: [Next](@next)
