import SwiftUI

/*:
 # What's New In SwiftUI

 Add sessions callout here.
*/

/*:
## Key Points
 * `Toolbar` - customizable to different positions
 * `Label` - straightforward API. Out of the box stacked image and text, with built-in support for dynamic text size
 * `help modifier` - out of the box Voice Over Accessibility on iOS, text context on macOS
 * 
*/

/*:
##  Learnings and Thoughts

 -> Description goes here <-
*/

// MARK: - Toolbar

struct ContentView: View {
    var body: some View {
        List {
            Text("Book Detail")
        }
        .toolbar {
            ToolbarItem {
                Button(action: recordProgress) {
                    Label("Progress", systemImage: "book.circle")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: shareBook) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }

    private func recordProgress() {}
    private func shareBook() {}
}

// MARK: - Label

struct AnotherContentView: View {
    var body: some View {
        List {
            Group {
                Label("Introducing SwiftUI", systemImage: "hand.wave")
                Label("SwiftUI Essentials", systemImage: "studentdesk")
                Label("Data Essentials in SwiftUI", systemImage: "flowchart")
                Label("App Essentials in SwiftUI", systemImage: "macwindow.on.rectangle")
            }
            Group {
                Label("Build Document-based apps in SwiftUI", systemImage: "doc")
                Label("Stacks, Grids, and Outlines", systemImage: "list.bullet.rectangle")
                Label("Building Custom Views in SwiftUI", systemImage: "sparkles")
                Label("Build SwiftUI Apps for tvOS", systemImage: "tv")
                Label("Build SwiftUI Views for Widgets", systemImage: "square.grid.2x2.fill")
                Label("Create Complications for Apple Watch", systemImage: "gauge")
                Label("SwiftUI on All Devices", systemImage: "laptopcomputer.and.iphone")
                Label("Integrating SwiftUI", systemImage: "rectangle.connected.to.line.below")
            }
        }
    }
}

//: [Previous](@previous) |
//: [Next](@next)
