import SwiftUI

/*:
 # Data Essentials in SwiftUI

 Add sessions callout here.
*/

/*:
## Key Points

 * Questions when designing a SwiftUI view:
    * 1. What `data` does the `view need` to do its job? (aka `view model`)
    * 2. How will the view `manipulate` that data? (or `actions` it will have, which will affect the underlying models)
    * 3. Where will the data come from? - `Source of truth` - `most important` question in the `design of the data model`

 * How to answer them:
     * 1. Properties for data that isn't changed - raw structs / value types
     * 2. @State for transient data owned by the view
     * 3. @Binding for mutating data owned by another view

 * Static subviews should have let properties, and receive data from parent view - a raw struct.

 * Views get cleaned up in each render cycle, but @State properties are kept and re-linked to the next created view objects

 * A @Binding is a property that connects to a state object of a superview, and keeps a single sour e of truth
    * A read/write reference to the existent data
    * SwiftUI knows when a value has changed and then re-render the views
    * The `$` creates a binding to the state, when passing-in to the child view - because the projectedValue of the State property wrapper is a Binding

 * ObservableObject
    * Protocol requirements:
        * Reference types only
        * A publisher that emits before the object has changed
    * The `$` creates a binding to the state, when passing-in to the child view - because the projectedValue of the State property wrapper is a Binding

*/

/*:
##  For subviews / smaller chunks / cells

 - When the view doesn't have any action, is static
 - Data can be let and injected from superview
*/

struct Book: Equatable {
    let coverName: String
    let author: String
    let title: String
    let progress: Float
}

struct BookCard : View {
    let book: Book
    let progress: Double

    var body: some View {
        HStack {
            Cover(book.coverName)
            VStack(alignment: .leading) {
                TitleText(book.title)
                AuthorText(book.author)
            }
            Spacer()
            RingProgressView(value: book.progress)
        }
    }
}

/*:
##  For child views with bindings

 - When the child view manipulates/changes the state
 - Data are passed in thorough a binding, that connects parent view state and child state
*/

struct EditorConfig {
    var isEditorPresented = false
    var note = ""
    var progress: Double = 0
}

struct BookView: View {
    @State private var editorConfig = EditorConfig()

    var body: some View {
        ProgressEditor(editorConfig: $editorConfig)
    }
}

struct ProgressEditor: View {
    @Binding var editorConfig: EditorConfig

    var body: some View {
        TextEditor($editorConfig.note)
    }
}

//: [Previous](@previous) |
//: [Next](@next)
