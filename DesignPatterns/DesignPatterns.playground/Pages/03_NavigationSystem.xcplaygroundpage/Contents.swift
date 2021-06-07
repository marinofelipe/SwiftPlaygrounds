/*:
 # Navigation System
 */

/*:
## References / Bibliografy

Some inspirations:
 - https://github.com/rockbruno/RouterService
 - https://speakerdeck.com/amiekweon/the-evolution-of-routing-at-airbnb?slide=50
*/

/*:
##  Content
*/

// MARK: - Goals

// MARK: - Brainstorm

// chain of routes - subroutes - paths

//struct Route<Environment, Input> {
//    let child: [Route]
//    let deepLinkPath: String
//    let environment: Environment
//    let startHandler: (Input) -> Void
//
//    func start(input: Input) {
//        startHandler(input)
//    }
//}
//
//protocol RouteY {
////    var child: [RouteY] { get }
////    let deepLinkPath: String
//    let environment: Environment
//    let startHandler: (Input) -> Void
//
//    func start(input: Input) {
//        startHandler(input)
//    }
//}
//
//struct Input {
//    let int: Int
//}
//
//
//
///activity/123

public struct ModuleDependencies {
    let dependencyA: Int
    let dependencyB: Bool

    public init(
        dependencyA: Int,
        dependencyB: Bool
    ) {
        self.dependencyA = dependencyA
        self.dependencyB = dependencyB
    }
}

import Foundation

public struct ModuleEnvironment {
    var doSomething: (Int) -> Void

    public static func makeLive(
        dependencies: ModuleDependencies
    ) -> Self {
        .init { id in
            print(id)
        }
    }
}

// ModuleInterface / Routes
//
//public struct ModuleDependencies {
//    let dependencyA: Int
//    let dependencyB: Bool
//
//    public init(
//        dependencyA: Int,
//        dependencyB: Bool
//    ) {
//        self.dependencyA = dependencyA
//        self.dependencyB = dependencyB
//    }
//}

// Route / Dependencies / Params

//struct Route {
//    let params: [Int]
//    let moduleEnvironment: ModuleEnvironment
//}

// call site
//
//protocol ModuleRoute: AnyObject {
//    associatedtype Environment
//    associatedtype Input
//
//    func start(
//        environment: Environment,
//        input: Input
//    ) -> AnyObject // coordinator reference
//}
//
//struct ModuleRoute<Environment, Input> {
//    let environment: Environment
//    let input: Input
//    let coordinatorCallback: (AnyObject?) -> Void
//}
//
//struct ActivityDetailsRouteInput {
//    let id: Int
//}
//
//struct ActivityDetailsRoute: ModuleRoute<ModuleEnvironment, ActivityDetailsRouteInput> {
//
//}

//protocol RouteHandler {
//    func start(route: ModuleRoute)
//}

struct Route<Input> {
    let input: Input
}

enum CheckoutRoute {
    case bookingAssistant(activityID: Int)
    case billing(selectedOptionID: Int, startingTime: String)
}

protocol RouteHandler {
    func start(route: Route)
}


//
//final class ActivityDetailsCoordinator: ActivityDetailsRoute {
//    let environment: ModuleEnvironment
//
//    init(environment: ModuleEnvironment) {
//        self.environment = environment
//    }
//
//    func start(input: ModuleDependencies) {
//
//    }
//}
//
//var route: ActivityDetailsRoute? = nil
//route?.start(input: .init(dependencyA: 1, dependencyB: true))
//
//final class ModulesRouteRegisterService {
//    static var routesMap: [String: AnyObject] = [:]
//
//    func register<R: ModuleRoute>(routes: R...) {
//        routes.forEach { route in
//            Self.routesMap[""] = route
//        }
//    }
//}

//protocol ActivityDetailsRoute: ModuleRoute {
//    func start(
//        environment: ModuleEnvironment,
//        parameters: ModuleDependencies
//    ) -> AnyObject // coordinator reference
//}

// MARK: - Strategy A

// each module declare their routes in an interface target
// modules import the interface
// main module provides an implementation - has a registration service

// MARK: - Strategy B

// single interface module with all public routes??
//



//: [Previous](@previous) |
//: [Next](@next)
