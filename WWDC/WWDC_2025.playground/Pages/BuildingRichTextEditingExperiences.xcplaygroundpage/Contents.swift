/*:
 # Building Rich Text Editing Experiences with SwiftUI
 
 [WWDC video](https://developer.apple.com/videos/play/wwdc2025/10148)
 
 ## Overview
 
 This playground explores how to build rich text editing experiences in SwiftUI using attributed strings, 
 as presented by Max (SwiftUI engineer) and Jeremy (Swift Standard Libraries engineer) at WWDC 2025.
 
 ## Key Concepts
 
 ### Upgrading to Rich Text with AttributedString
 
 Transform a basic text editor to support rich text by changing from `String` to `AttributedString`:
 
 ```swift
 // Before: Plain text
 @State private var text: String = ""
 
 // After: Rich text support
 @State private var text: AttributedString = AttributedString()
 ```
 
 ### AttributedString Basics
 
 An `AttributedString` contains:
 - A sequence of characters (UTF-8 encoded)
 - Attribute runs that define formatting
 - Conforms to `Equatable`, `Hashable`, `Codable`, and `Sendable`
 
 ### Selection Handling
 
 SwiftUI uses `AttributedTextSelection` which represents selections as a set of ranges rather than a single range.
 This is essential for bidirectional text support (e.g., English + Hebrew).
 
 ### Custom Attributes
 
 Define custom attributes for specialized formatting:
 
 ```swift
 struct IngredientAttribute: AttributedStringKey {
     typealias Value = String // Ingredient ID
     static let name = "ingredient"
 }
 ```
 
 ### Mutation and Index Management
 
 When mutating `AttributedString`, use the `transform` function to properly update indices and selections:
 
 ```swift
 text.transform { text in
     // Safe mutation that preserves indices
     text[range] = newValue
 }
 ```
 
 ### Custom Text Formatting Definition
 
 Use `AttributedTextFormattingDefinition` to control which attributes are editable:
 
 ```swift
 struct CustomFormattingDefinition: AttributedTextFormattingDefinition {
     var attributeScopes: [AttributeScope.Type] = [
         AttributeScopes.SwiftUIAttributes.self,
         AttributeScopes.FoundationAttributes.self
     ]
 }
 ```
 
 ### Attribute Constraints
 
 Implement `AttributedTextValueConstraint` to enforce formatting rules:
 
 ```swift
 struct IngredientColorConstraint: AttributedTextValueConstraint {
     func constrainValue(_ value: Color, to range: Range<AttributedString.Index>, in text: AttributedString) -> Color {
         return text[range].ingredient != nil ? .green : value
     }
 }
 ```
 
 ## Key Behaviors
 
 ### Attribute Inheritance
 
 Control how attributes behave when text is added or modified:
 
 - `inheritedByAddedText`: Determines if new text inherits the attribute
 - `invalidationConditions`: Specifies when attributes should be removed
 - `runBoundaries`: Enforces consistent values across text sections
 
 ### Example: Recipe Editor
 
 The presentation demonstrates these concepts through a recipe editor that:
 1. Supports rich text formatting (bold, italic, colors)
 2. Marks ingredients with custom attributes
 3. Highlights ingredients in green
 4. Maintains proper selection behavior during text mutation
 5. Provides ingredient suggestion functionality
 
 ## Best Practices
 
 1. **Use `transform` for mutations**: Always use the transform function when mutating attributed strings to maintain index validity
 2. **Handle selections properly**: Work with range sets rather than single ranges for robust text selection
 3. **Define custom attributes carefully**: Consider inheritance and invalidation behaviors
 4. **Test with bidirectional text**: Ensure your implementation works with mixed writing directions
 5. **Leverage constraints**: Use formatting constraints to enforce consistent styling rules
 
 ## Performance Considerations
 
 - AttributedString uses efficient UTF-8 encoding
 - Attribute runs are optimized for common formatting patterns
 - Custom attributes should be lightweight value types
 - Use range operations efficiently to avoid unnecessary string copying
 
 ---
 
 *This playground page summarizes the "Building Rich Text Editing Experiences with SwiftUI" session from WWDC 2025.*
 */

import SwiftUI
import Foundation

struct RecipeEditorExample: View {
    @State private var recipeText = AttributedString("Add your recipe ingredients here...")
    @State private var selection: AttributedTextSelection = .init()
    
    var body: some View {
        VStack {
            TextEditor(text: $recipeText, selection: $selection)
                .font(.body)
                .padding()
                .border(Color.gray, width: 1)
            
          Text("Selection: \($selection.debugDescription)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Building Rich Text Editing Experiences")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("WWDC 2025 Session Summary")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                RecipeEditorExample()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Rich Text Editing")
        }
    }
}

ContentView()

//: [Next page](@next)
