/*:
 # Some

 Desc
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
##  Learnings and Thoughts

 #### Identifiable x Equatable

 Identifiable distinguishes the identity of an entity from its state.

 A parcel from our previous example will change locations frequently as it travels to its recipient. Yet a normal equality check (==) would fail the moment it leaves its sender:
*/

import Combine
import UIKit

protocol ViewModelProtocol<ViewState, Action> {
    associatedtype ViewState: Equatable
    associatedtype Action: Equatable

    var viewState: AnyPublisher<ViewState, Never> { get }

    func send(_ action: Action)
}

protocol ViewModelThatTracks {
    var tracker: any TrackerProtocol { get }
}

extension ViewModelProtocol where Self: ViewModelThatTracks, Action == ViewModelAction { // where Action == ViewModelAction {
    func handle(_ action: ViewModelAction) {
        switch action {
        case .viewDidAppear:
//            tracker.track(<#T##event: TrackerProtocol.Event##TrackerProtocol.Event#>)
            break
        case .viewDidLoad:
            break
        default:
            break
        }

//        #if DEBUG
        print(">>> view model \(self) received action: \(action)") // log instead
//        #endif
    }
}

enum ProfileViewState: Equatable {
    case loaded(title: String)
    case loading
}

struct ViewModelAction: RawRepresentable, Equatable {
    typealias RawValue = String
    var rawValue: String
}

extension ViewModelAction {
    static let viewDidAppear: ViewModelAction = .init(rawValue: "viewDidAppear")
    static let viewDidLoad: ViewModelAction = .init(rawValue: "viewDidLoad")
}

extension ViewModelAction {
    static let tapCTA: ViewModelAction = .init(rawValue: "tapCTA")
    static let tapClose: ViewModelAction = .init(rawValue: "tapClose")
}

//enum ProfileAction: Equatable {
//    case `default`(ViewModelAction)
//    case viewDidLoad
//}

//extension ViewModelProtocol where Action

final class ProfileViewModel: ViewModelProtocol {
    typealias ViewState = ProfileViewState
    typealias Action = ViewModelAction

    var viewState: AnyPublisher<ProfileViewState, Never> = CurrentValueSubject(.loading)
        .eraseToAnyPublisher()

    init() {

    }

    func send(_ action: ViewModelAction) {
        switch action {
        case .viewDidAppear:
            print(">>> viewDidAppear")
        default:
            break
        }
    }
}

final class ProfileViewController: UIViewController {
    private let viewModel: any ViewModelProtocol<ProfileViewState, ViewModelAction>
    private var disposeBag = Set<AnyCancellable>()

    init(viewModel: some ViewModelProtocol<ProfileViewState, ViewModelAction> = ProfileViewModel()) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.viewState
            .sink { viewState in
                print(">>> \(viewState)")
            }
            .store(in: &disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.send(.viewDidAppear)
    }
}

// tracker

// tracker

protocol TrackerProtocol<Event> {
    associatedtype Event: Equatable

    func track(_ event: Event)
}

enum ProfileTrackingEvent: Equatable {
    case view(id: String)
}

struct TrackingEvent: RawRepresentable, Equatable {
    typealias RawValue = String
    var rawValue: String
}

final class ProfileTracker: TrackerProtocol {
    typealias Event = ProfileTrackingEvent

    func track(_ event: ProfileTrackingEvent) {
        switch event {
        case let .view(id):
            print(">>> \(id)")
        }
    }
}

let vc = ProfileViewController()
vc.viewDidLoad()
vc.viewDidAppear(true)

//: [Previous](@previous) |
//: [Next](@next)
