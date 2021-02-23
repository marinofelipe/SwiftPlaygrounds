/*:
 # Strengthened Types
 */

/*:
## References / Bibliografy

Heavily inspired/based on:
 - [Point Free - Episode 12 - Tagged](https://www.pointfree.co/episodes/ep12-tagged)
*/

/*:
##  Content
*/

// MARK: - Too general

/// `Types` sometimes are `far too general` for the `data they represent`

struct Option {
    let id: Int
    let name: String
    let price: Decimal
    let activityID: Int
}

struct Activity {
    let id: Int
    let name: String
    let city: String
}

let option = Option(
    id: 2,
    name: "Option",
    price: 12.99,
    activityID: 5
)

let activity = Activity(
    id: 5,
    name: "Hiking in Oberstdorf",
    city: "Oberstdorf"
)

func bookActivity(id: Int) {
    __
}

bookActivity(id: option.id)
bookActivity(id: activity.id)

// MARK: - Typed ID

struct Activity2 {
    struct ID {
        let id: Int
    }
    let id: ID
    let name: String
    let city: String
}

let activity2 = Activity2(
    id: .init(id: 5),
    name: "Swimming in Baviera",
    city: "Fussen"
)

func bookActivity(withID id: Activity2.ID) {
    __
}

// bookActivity(withID: option.id) // error: cannot convert value of type 'Int' to expected argument type 'Activity2.ID'
// bookActivity(withID: activity.id) // error: cannot convert value of type 'Int' to expected argument type 'Activity2.ID'
bookActivity(withID: activity2.id)

// MARK: - RawRepresentable

// ExpressibleByIntegerLiteral is just added for fun as a matter of making the API more convenient
struct Activity3 {
    struct ID: RawRepresentable, ExpressibleByIntegerLiteral, Equatable {
        let rawValue: Int

        init(integerLiteral value: Int) {
            self.rawValue = value
        }

        init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    let id: ID
    let name: String
    let city: String
}

let options = (0...3).map { index in
    Option(
        id: index,
        name: "Option",
        price: 12.99,
        activityID: 5
    )
}

options
    .first(where: { $0.id == activity.id }) // Allowed to

// with strongly typed activity id

struct Option2 {
    let id: Int
    let name: String
    let price: Decimal
    let activityID: Activity3.ID
}

let options2 = (0...3).map { index in
    Option2(
        id: index,
        name: "Option",
        price: 12.99,
        activityID: 5
    )
}

let activity3 = Activity3(
    id: 5,
    name: "Name",
    city: "City"
)

//options2
//    .first(where: { $0.activityID == activity.id }) // error: cannot convert value of type 'Activity3.ID' to expected argument type 'Int'

options2
    .first(where: { $0.activityID == activity3.id }) // Type matches

// MARK: - All purpose

// Tag is a phantom type, used so to distinguish between different tagged types
struct Tagged<Tag, RawValue> {
    let rawValue: RawValue
}

//extension Tagged: ExpressibleByIntegerLiteral where RawValue == Int {
//    init(integerLiteral value: Int) {
//        self.rawValue = value
//    }
//}

extension Tagged: ExpressibleByIntegerLiteral
where RawValue: ExpressibleByIntegerLiteral {
  typealias IntegerLiteralType = RawValue.IntegerLiteralType

  init(integerLiteral value: IntegerLiteralType) {
    self.init(rawValue: RawValue(integerLiteral: value))
  }
}

extension Tagged: ExpressibleByStringLiteral
where RawValue: ExpressibleByStringLiteral {
    typealias StringLiteralType = RawValue.StringLiteralType

    init(stringLiteral value: Self.StringLiteralType) {
        self.init(rawValue: RawValue(stringLiteral: value))
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral
where RawValue: ExpressibleByUnicodeScalarLiteral {
    typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType

    init(unicodeScalarLiteral value: Self.UnicodeScalarLiteralType) {
        self.init(rawValue: RawValue(unicodeScalarLiteral: value))
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral
where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType

    init(extendedGraphemeClusterLiteral value: Self.ExtendedGraphemeClusterLiteralType) {
        self.init(rawValue: RawValue(extendedGraphemeClusterLiteral: value))
    }
}

extension Tagged: Equatable where RawValue: Equatable { }
extension Tagged: Decodable where RawValue: Decodable { }

extension Tagged: Comparable where RawValue: Comparable {
    static func < (
        lhs: Tagged<Tag, RawValue>,
        rhs: Tagged<Tag, RawValue>
    ) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

struct TaggedActivity: Equatable {
    typealias ID = Tagged<TaggedActivity, Int>

    let id: ID
    let name: String
    let city: String
}

let taggedActivity = TaggedActivity(
    id: 5,
    name: "name",
    city: "city"
)

struct Option4 {
    typealias ID = Tagged<Option4, Int>

    let id: ID
    let name: String
    let price: Decimal
    let activityID: TaggedActivity.ID
}

let options4 = (0...3).map { index in
    Option4(
        id: .init(integerLiteral: index),
        name: "Option",
        price: 12.99,
        activityID: 5
    )
}

var ids = options4.map(\.id)
ids.append(5)

options4
    .first(where: { $0.activityID == taggedActivity.id })
//options4
//    .first(where: { $0.activityID == activity.id })


//: [Previous](@previous) |
//: [Next](@next)
