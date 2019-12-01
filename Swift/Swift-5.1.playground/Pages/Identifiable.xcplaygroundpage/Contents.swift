/*:
 # Indentifiable protocol

 Types that adopt Identifiable provide an ID of Hashable associated type. So its values / objects can be easily tracked and identified.

 > A class of types whose instances hold the value of an entity with stable identity.

 ```
 protocol Identifiable {
     associatedtype ID: Hashable
     var id: ID { get }
 }
 ```
 */

/*:
## Proposal

The Swift Evolution proposal for Identifiable: [SE-0261](https://github.com/apple/swift-evolution/blob/master/proposals/0261-identifiable.md).
 */

/*:
## References / Bibliografy

The examples and analyses are heavily inspired by:
 - [Identifiable](https://nshipster.com/identifiable/) - by NSHipster, August, 26, 2019
 */

/*:
##  Example

 Example:

 A Parcel object may use the id property requirement to track the package en route to its final destination. No matter where the package goes, it can always be looked up by its id:
 */

import MapKit

struct Parcel: Identifiable {
    let id: String
    var location: CLLocation?
}

/*:
##  Learnings and Thoughts

 #### Identifiable x Equatable

 Identifiable distinguishes the identity of an entity from its state.

 A parcel from our previous example will change locations frequently as it travels to its recipient. Yet a normal equality check (==) would fail the moment it leaves its sender:
*/

extension Parcel: Equatable {}

var specialDelivery = Parcel(id: "123456789012")
specialDelivery.location = CLLocation(latitude: 40.0, longitude: -20.0)

specialDelivery == Parcel(id: "123456789012") // false
specialDelivery.id == Parcel(id: "123456789012").id // true

/*:
While this is an expected outcome from a small, contrived example, the very same behavior can lead to confusing results further down the stack, where you’re not as clear about how different parts work with one another.
*/

extension Parcel: Hashable {}

var trackedPackages: Set<Parcel> = [specialDelivery]
trackedPackages.contains(Parcel(id: "123456789012")) // false (?)

/*:
On the subject of Set, let’s take a moment to talk about the Hashable protocol.
*/

/*:
 #### Identifiable x Hashable

 Although the hash value used to bucket collection elements may bear a passing resemblance to identifiers, Hashable and Identifiable have some important distinctions in their underlying semantics:

 - Unlike identifiers, hash values are typically state-dependent, changing when an object is mutated.
 - Identifiers are stable across launches, whereas hash values are calculated by randomly generated hash seeds, making them unstable between launches.
 - Identifiers are unique, whereas hash values may collide, requiring additional equality checks when fetched from a collection.
 - Identifiers can be meaningful, whereas hash values are chaotic by virtue of their hashing functions.
*/

/*:
 ### Choosing ID types

 #### Int as ID

 The great thing about using integers as identifiers is that (at least on 64-bit systems), you’re unlikely to run out of them anytime soon.

 Most systems that use integers to identify records assign them in an auto-incrementing manner, such that each new ID is 1 more than the last one. Here’s a simple example of how you can do this in Swift:
*/

struct Widget: Identifiable {
    private static var idSequence = sequence(first: 1, next: {$0 + 1})

    let id: Int

    init?() {
        guard let id = Widget.idSequence.next() else { return nil}
        self.id = id
    }
}

Widget()?.id // 1
Widget()?.id // 2
Widget()?.id // 3

/*:
 #### UUID as ID

 Foundation provides a built-in implementation of (version-4) UUIDs by way of the UUID type. Thus making adoption to Identifiable with UUIDs trivial.
 Beyond minor ergonomic and cosmetic issues, UUID serves as an excellent alternative to Int for generated identifiers.
*/

import Foundation

struct Gadget: Identifiable {
    let id = UUID()
}

Gadget().id // Ex: 584FB4BA-0C1D-4107-9EE5-C555501F2077
Gadget().id // Ex: C9FECDCC-37B3-4AEE-A514-64F9F53E74BA

/*:
 >Because what Identifiable does is kind of amazing: it extends reference semantics to value types.
 */

/*:
## Freeplay
 */

import SwiftUI

struct ExampleView : View {

    enum FilterType: String, CaseIterable, Identifiable {
        case price = "Price"
        case distance = "Distance"
        case upcoming = "Upcoming"

        var id: String {
            return rawValue
        }
    }

    @State var selectedFilter: FilterType = .price

    var filterPicker: some View {
        Picker("Filter", selection: $selectedFilter) {
            ForEach(FilterType.allCases) { filterType in
                Text(filterType.rawValue).tag(filterType)
            }
        }
        .padding(.all)
    }

    var body: some View {
        filterPicker
    }
}
//: [Previous](@previous) |
//: [Next](@next)
