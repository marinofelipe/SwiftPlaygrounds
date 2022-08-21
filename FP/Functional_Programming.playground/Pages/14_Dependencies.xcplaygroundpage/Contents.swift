/*:
 # Dependencies
 */

/*:
## References / Bibliografy

Heavily inspired/based on:
 - [Point Free - Episode 18](https://www.pointfree.co/episodes/ep18-dependency-injection-made-comfortable)
*/

/*:
##  Content
*/

// Environments as we are used to
// Combined with Overture library gives some nice compositional power

struct GitHub {
    struct Repo: Decodable {
        var archived: Bool
        var description: String?
        var htmlUrl: URL
        var name: String
        var pushedAt: Date?
    }

    //  var fetchRepos = fetchRepos(onComplete:)
}

//extension GitHub {
//    static let mock = GitHub(fetchRepos: { callback in
//        callback([.mock])
//    })
//}
//
//extension Array where Element == GitHub.Repo {
//    static let mock = [
//        GitHub.Repo.mock,
//    ]
//}
//
//// + Overture
//extension Array where Element == GitHub.Repo {
//  static let mock = [
//    GitHub.Repo.mock,
//    with(.mock, concat(
//      set(\.name, "Nomadic Blob"),
//      set(\.description, "Where in the world is Blob?"),
//      set(\GitHub.Repo.pushedAt, .mock - 60*60*24*2)
//    ))
//  ]
//}

//: [Previous](@previous) |
//: [Next](@next)
