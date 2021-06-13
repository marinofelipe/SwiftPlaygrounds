import SwiftUI

/*:
 # Meet async/await in Swift

 [Session video](https://developer.apple.com/wwdc21/10132)
*/

/*:
## Notes

 - Nowadays
    - Complex, verbose, error prone
    - It's easy to forget to call completion handlers in some paths
    - You can cover, or should always do, all cases with tests, but there's no compile time guarantees that the completion is called for all possible cases
        - No way to enforce that a closure is always called
    - In a completion handler world, there's no way the compiler can guarantee that if a value is not returned, an error is thrown, what is the case on sync functions
    - Nested operations are nested; easy to mess things up; a lot lines of code
    -

 - Async
    - Makes code that runs async be exposed via sync interfaces
    - Way easier for callers
    - Safer
    - Shorter
    - Compile time guarantee of return on all scope paths
    - Properties can also be async

 - Await
    - Blocks the thread ??
    - If that's the behavior, I expect should never be called from the main thread
    - `Suspends` the current scope/function and gives control of the thread to the system
    - `Can suspend or not` while the async work runs - _Still need to better understand if this behavior is controlled or all decided by the system. I'd expect priorities and different queues to have the same effect on priority for suspension as there is on GCD._

 - To remember
    - `async` allows a function to suspend
    - `await` marks _where_ an async function may suspend execution
    - other work can happen while an async func is suspended, the thread won't block
 */

// MARK: - completion handler based

func fetchThumbnail(for id: String, completion: @escaping (UIImage?, Error?) -> Void) {
    let request = thumbnailURLRequest(for: id)
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(nil, error)
        } else if (response as? HTTPURLResponse)?.statusCode != 200 {
            completion(nil, FetchError.badID)
        } else {
            guard let image = UIImage(data: data!) else {
                completion(nil, FetchError.badImage)
                return
            }
            image.prepareThumbnail(of: CGSize(width: 40, height: 40)) { thumbnail in
                guard let thumbnail = thumbnail else {
                    completion(nil, FetchError.badImage)
                    return
                }
                completion(thumbnail, nil)
            }
        }
    }
    task.resume()
}

// MARK: - async await

func fetchThumbnail(for id: String) async throws -> UIImage {
    let request = thumbnailURLRequest(for: id)
    let (data, response) = try await URLSession.shared.data(for: request)
    guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw FetchError.badID }
    let maybeImage = UIImage(data: data)
    guard let thumbnail = await maybeImage?.thumbnail else { throw FetchError.badImage }
    return thumbnail
}

// MARK: - async property

extension UIImage {
    var thumbnail: UIImage? {
        get async {
            let size = CGSize(width: 40, height: 40)
            return await self.byPreparingThumbnail(ofSize: size)
        }
    }
}

// MARK: - async sequence

for await id in staticImageIDsURL.lines {
    let thumbnail = await fetchThumbnail(for: id)
    collage.add(thumbnail)
}
let result = await collage.draw()

// MARK: - testing

// no more expectations

// from
class MockViewModelSpec: XCTestCase {
    func testFetchThumbnails() throws {
        let expectation = XCTestExpectation(description: "mock thumbnails completion")
        self.mockViewModel.fetchThumbnail(for: mockID) { result, error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5.0)
    }
}

// to
class MockViewModelSpec: XCTestCase {
    func testFetchThumbnails() async throws {
        XCTAssertNoThrow(try await self.mockViewModel.fetchThumbnail(for: mockID))
    }
}

/// `Q`: What about timeouts?? 👆

// MARK: - Bringing the gap between sync and async worlds

struct ThumbnailView: View {
    @ObservedObject var viewModel: ViewModel
    var post: Post
    @State private var image: UIImage?

    var body: some View {
        Image(uiImage: self.image ?? placeholder)
            .onAppear {
                /// This piece of block here!!!
                /// async task function:
                /// sends to system for execution on next available thread
                /// like async on Global dispatch queue
                /// `main benefit` - **async code called from sync contexts**
                ///
                /// Me: "I hope the compiler knows that the execution here should be on main, or that there are ways of deciding which thread"
                async {
                    self.image = try? await self.viewModel.fetchThumbnail(for: post.id)
                }
            }
    }
}

// MARK: - Migration recommendations

// 1. Adopted gradually
// 2. Async alternatives for completion handler based APIs
// 3. Xcode's async refactoring actions can help - "Hmmm, nein.. I doubt from experience from Swidt 2/3 auto migrations, or the same on Objc -> Swift, but why not giving another chance?"
// 4. Remove naming prefixes like `get` that relates to "old async", since with async/await the data is returned synchronously
// 5. Use continuations for briding

// MARK: - Continuations

/// For bridging from completion based or delegate based APIs to async await

// Case 1 - from completion based

// Existing function
func getPersistentPosts(completion: @escaping ([Post], Error?) -> Void) {
    do {
        let req = Post.fetchRequest()
        req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        let asyncRequest = NSAsynchronousFetchRequest<Post>(fetchRequest: req) { result in
            completion(result.finalResult ?? [], nil)
        }
        try self.managedObjectContext.execute(asyncRequest)
    } catch {
        completion([], error)
    }
}

// Async alternative
func persistentPosts() async throws -> [Post] {
    typealias PostContinuation = CheckedContinuation<[Post], Error>
    return try await withCheckedThrowingContinuation { (continuation: PostContinuation) in
        self.getPersistentPosts { posts, error in
            if let error = error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: posts)
            }
        }
    }
}

// Case 2 - from delegate based

class ViewController: UIViewController {
    private var activeContinuation: CheckedContinuation<[Post], Error>?
    func sharedPostsFromPeer() async throws -> [Post] {
        try await withCheckedThrowingContinuation { continuation in
            self.activeContinuation = continuation
            self.peerManager.syncSharedPosts()
        }
    }
}

extension ViewController: PeerSyncDelegate {
    func peerManager(_ manager: PeerManager, received posts: [Post]) {
        self.activeContinuation?.resume(returning: posts)
        self.activeContinuation = nil // guard against multiple calls to resume
    }

    func peerManager(_ manager: PeerManager, hadError error: Error) {
        self.activeContinuation?.resume(throwing: error)
        self.activeContinuation = nil // guard against multiple calls to resume
    }
}

// MARK: - Exercises

/// Play with it on one of my pet projects

//: [Previous](@previous) |
//: [Next](@next)
