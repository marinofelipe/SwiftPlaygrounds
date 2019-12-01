/*:
 # Property Wrappers

A property wrapper type provides the storage for a property that uses it as a wrapper. The wrappedValue property of the wrapper type provides the actual implementation of the wrapper, while the (optional) init(wrappedValue:) enables initialization of the storage from a value of the property's type.

 */

/*:
## Proposal

The Swift Evolution proposal for Property Wrappers: [SE-0258](https://github.com/apple/swift-evolution/blob/master/proposals/0258-property-wrappers.md).
 */

/*:
## References / Bibliografy

 */

/*:
##  Example

 Example:

 Allow a property declaration to state which wrapper is used to implement it. The wrapper is described via an attribute.
 This implements the property foo in a way described by the property wrapper type for Lazy:

 */

@Lazy var foo = 1738

@propertyWrapper
enum Lazy<Value> {
  case uninitialized(() -> Value)
  case initialized(Value)

  init(wrappedValue: @autoclosure @escaping () -> Value) {
    self = .uninitialized(wrappedValue)
  }

  var wrappedValue: Value {
    mutating get {
      switch self {
      case .uninitialized(let initializer):
        let value = initializer()
        self = .initialized(value)
        return value
      case .initialized(let value):
        return value
      }
    }
    set {
      self = .initialized(newValue)
    }
  }
}

/*:
##  Learnings and Thoughts

 // TODO:

*/

//: [Previous](@previous) |
//: [Next](@next)
