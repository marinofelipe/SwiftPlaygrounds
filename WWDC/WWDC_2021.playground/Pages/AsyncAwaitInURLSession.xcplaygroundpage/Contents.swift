/*:
 # Use async/await with URLSession

 [Session video](https://developer.apple.com/wwdc21/10095)
*/

/*:
## Notes

 - linear control flow
 - Bye bye madness.
    - Easier to handle all paths, given the compiler is there to ensure there's a return
    - Ensure everything runs in the same threading context
 */

//MARK: - Fetch photo with old API



//MARK: - Fetch photo with async/await

func fetchPhoto(url: URL) async throws -> UIImage
{
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          httpResponse.statusCode == 200 else {
        throw WoofError.invalidServerResponse
    }

    guard let image = UIImage(data: data) else {
        throw WoofError.unsupportedImage
    }

    return image
}

// data - APIs for either URL or URLRequest

let (data, response) = try await URLSession.shared.data(from: url)
guard let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 200 /* OK */ else {
    throw MyNetworkingError.invalidServerResponse
}

// upload - From Data or file

var request = URLRequest(url: url)
request.httpMethod = "POST"

let (data, response) = try await URLSession.shared.upload(for: request, fromFile: fileURL)
guard let httpResponse = response as? HTTPURLResponse,
      httpResponse.statusCode == 201 /* Created */ else {
    throw MyNetworkingError.invalidServerResponse
}

// MARK: - Cancellation

let handle = async {
    let (data1, response1) = try await URLSession.shared.data(from: url1)
    let (data2, response2) = try await URLSession.shared.data(from: url2)
}
handle.cancel()

// MARK: Async.Bytes / AsyncSequence

// Built-in transformations
// System frameworks support

let (bytes, response) = try await URLSession.shared.bytes(from: Self.eventStreamURL)
guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
    throw WoofError.invalidServerResponse
}
for try await line in bytes.lines {
    let photoMetadata = try JSONDecoder().decode(PhotoMetadata.self, from: Data(line.utf8))
    await updateFavoriteCount(with: photoMetadata)
}

// MARK: - Authentication challenges

// delegate is used for that
// it is strongly captured by the task until it completes or fails
// can be used to handle events specific to an instance of a URLSession task
// Handy to apply logic to specific tasks

final class AuthenticationDelegate: NSObject, URLSessionTaskDelegate {
    private let signInController: SignInController

    init(signInController: SignInController) {
        self.signInController = signInController
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didReceive challenge: URLAuthenticationChallenge) async
    -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            do {
                let (username, password) = try await signInController.promptForCredential()
                return (.useCredential,
                        URLCredential(user: username, password: password, persistence: .forSession))
            } catch {
                return (.cancelAuthenticationChallenge, nil)
            }
        } else {
            return (.performDefaultHandling, nil)
        }
    }
}

// MARK: - Exercises


//: [Previous](@previous) |
//: [Next](@next)
