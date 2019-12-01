/*:
 # Key Paths

In short, KeyPaths are a type-safe way to separate referencing a type’s property, from evaluating that property, and getting a result back.

 > To avoid ambiguities with type properties, we propose we escape such expressions using \ to indicate that you are talking about the property, not its invocation.

 ```
 struct Player {
    var name: String
    var uniformNumber: Int
 }

 let harrisonSmith = Player(name: "Harrison Smith", uniformNumber: 22)
 let uniformNumber = harrisonSmith[keyPath: \.uniformNumber]
 ```
 */

/*:
## Proposal

Swift Evolution proposal [SE-0161](https://github.com/apple/swift-evolution/blob/master/proposals/0161-key-paths.md).
 */

/*:
## References / Bibliografy

The examples and analyses is heavily based on:
 - [Swift 4 Key Paths and you](https://www.klundberg.com/blog/swift-4-keypaths-and-you/) - by Kevin Lundberg, September, 06, 2017
 */

/*:
##  Learnings and Thoughts

 #### Swift 3..

 Identifiable distinguishes the identity of an entity from its state.

 A parcel from our previous example will change locations frequently as it travels to its recipient. Yet a normal equality check (==) would fail the moment it leaves its sender:
*/

/// Swift 3

/// Function
struct InexorableDeveloper {

    let preferredIDE: String

    func sellIDE() {
        print("The best IDE is \(preferredIDE)")
    }
}

let dev = InexorableDeveloper(preferredIDE: "Xcode")
let seller = dev.sellIDE // stores the method without evaluating it
seller() // calls the stored method

/// Property

// this is the only way in Swift 3.1 and below to defer evaluating the name property of a Person.
let getPreferredIDEInBlock = { (d: InexorableDeveloper) in d.preferredIDE }
print(getPreferredIDEInBlock(dev)) // evaluate the property


/// Swift 4

/// KeyPath

// With Swift 4 you can rewrite the last two lines above like so:
var preferredIDEKeyPath = \InexorableDeveloper.preferredIDE // reference the property Key Path
/// This forms a KeyPath<Developer, String> where the first generic parameter is the root type (what type we are querying), and the second generic parameter is the type of the value we are asking for.

print(dev[keyPath: preferredIDEKeyPath]) // evaluate the property

// or just
print(dev[keyPath: \InexorableDeveloper.preferredIDE]) // evaluate the property

// Querying more than one level
let preferredIDECountKeyPath = \InexorableDeveloper.preferredIDE.count // Stores the count of characters the preferredIDE has.
print(dev[keyPath: preferredIDECountKeyPath]) // evaluate the property - prints "5" - Xcode count

/// WritableKeyPath
/// In the example above preferredIDECount is a let, but what if we had a mutable property?
struct AdaptableDeveloper {
    var preferredIDE: String

    func sell() {
        print("The best IDE is \(preferredIDE)!")
    }
}

var anotherDev = AdaptableDeveloper(preferredIDE: "VisualCode")
let preferredIDEKeyPath2 = \AdaptableDeveloper.preferredIDE
anotherDev[keyPath: preferredIDEKeyPath2] = "Xcode"
anotherDev.sell() // Prints "The best IDE is Xcode!"

/// ReferenceWritableKeyPath

class SomeDeveloper {
    var preferredIDE: String = "None"
}

var someDev = SomeDeveloper()

let keyPath = \SomeDeveloper.preferredIDE
// keyPath is a ReferenceWritableKeyPath once it contains a mutable property of a class, therefore a reference mutation
someDev[keyPath: keyPath] = "Xcode" // someDev.preferredIDE value is now "Xcode"

/// PartialKeyPath

struct AnyDeveloper {
    var name: String
    var age: Int
}

let anyDev = AnyDeveloper(name: "Artur", age: 19)
let partialKeyPath: PartialKeyPath<AnyDeveloper> = \AnyDeveloper.name
type(of: anyDev[keyPath: partialKeyPath]) // returns Any

let anyDeveloperKeyPaths: [PartialKeyPath<AnyDeveloper>] = [
    \AnyDeveloper.name,
    \AnyDeveloper.age,
] // only possible with PartialKeyPath since name and age are different types


/// AnyKeyPath

let anyKeyPath: AnyKeyPath = \AnyDeveloper.age
// ???

// Combining Key Paths
struct Person {
  let birthPlanet: Planet
}

struct Planet {
  var name: String
}

let personBirthPlanetPath = \Person.birthPlanet
let planetNamePath = \Planet.name

let personBirthPlanetNamePath = personBirthPlanetPath.appending(path: planetNamePath) // returns KeyPath<Person, String>

let person = Person(birthPlanet: Planet(name: "Earth"))
person[keyPath: personBirthPlanetNamePath] // returns the name of the person's birth planet

///
///Combining KeyPaths has some other interesting behavior around how the types of the KeyPaths you combine affect the KeyPath you get back. For instance, appending a KeyPath and a WritableKeyPath gives you a read-only KeyPath since it’s not possible to mutate a property in the normal case either:
///
///
///
///
///The full table of ways you can combine KeyPaths and get different types back is below, for reference:

//First    Second    Result
//AnyKeyPath    Anything    AnyKeyPath?
//PartialKeyPath    AnyKeyPath or PartialKeyPath    PartialKeyPath?
//PartialKeyPath    KeyPath or WritableKeyPath    KeyPath?
//PartialKeyPath    ReferenceWritableKeyPath    ReferenceWritableKeyPath?
//KeyPath    AnyKeyPath or PartialKeyPath    💥 Not possible 💥
//KeyPath    KeyPath or WritableKeyPath    KeyPath
//KeyPath    ReferenceWritableKeyPath    ReferenceWritableKeyPath
//WritableKeyPath    AnyKeyPath or PartialKeyPath    💥 Not possible 💥
//WritableKeyPath    KeyPath    KeyPath
//WritableKeyPath    WritableKeyPath    WritableKeyPath
//WritableKeyPath    ReferenceWritableKeyPath    ReferenceWritableKeyPath
//ReferenceWritableKeyPath    AnyKeyPath or PartialKeyPath    💥 Not possible 💥
//ReferenceWritableKeyPath    KeyPath    KeyPath
//ReferenceWritableKeyPath    WritableKeyPath or ReferenceWritableKeyPath    ReferenceWritableKeyPath

// Optional Key Paths
struct One {
  var address: Address?
}

struct Address {
  var fullAddress: String
}

let kp = \One.address // returns WritableKeyPath<One, String?>
let akp = \Address.fullAddress

var one = One(address: Address(fullAddress: "Zimmerstr. 96"))
let a = one[keyPath: kp]?[keyPath: akp] // only way to append optional key paths, once the compiler complains about the optional root no matching the appending value.

/// Using subscripting in Key Paths
struct Pee {
  var previousAddresses: [Address]
}

let wtf = \Pee.previousAddresses[1].fullAddress

/// Inferred types in key paths
struct Country {
    var name: String
}

let germany = Country(name: "Germany")
let name = germany[keyPath: \.name] // beautiful

//: [Previous](@previous) |
//: [Next](@next)
