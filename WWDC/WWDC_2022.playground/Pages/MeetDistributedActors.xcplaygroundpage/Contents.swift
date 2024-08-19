import Foundation

/*:
 # Meet distributed actors in Swift

 [WWDC video](https://developer.apple.com/wwdc22/110356)
 */

/*:
 ## Key Points
 - Actor concepts expanded to multiple processes, devices or servers in a cluster
 - Location transparency
 - Doesn't matter where an actor is located, communication happens the same way
 */

import Distributed

public struct GameMove: Codable, Hashable {
  let id: Int
}

public struct GameState: Codable, Hashable {
  let id: Int

  func mark(_ move: GameMove) throws {
    print(move)
  }
}

public struct CharacterTeam: Codable, Hashable {
  let id: Int
}

public struct RandomPlayerBotAI: Codable, Hashable {
  let playerID: LocalTestingActorID
  let team: CharacterTeam

  func decideNextMove(given gameState: inout GameState) throws -> GameMove {
    GameMove(id: gameState.id)
  }
}

// Local distributed

public distributed actor BotPlayer: Identifiable {
  public typealias ActorSystem = LocalTestingDistributedActorSystem

  var ai: RandomPlayerBotAI
  var gameState: GameState

  public init(team: CharacterTeam, actorSystem: ActorSystem) {
    self.actorSystem = actorSystem // first, initialize the implicitly synthesized actor system property
    self.gameState = .init(id: 1)
    self.ai = RandomPlayerBotAI(playerID: self.id, team: team) // use the synthesized `id` property
  }

  // funcs that should be called remotely, also have the `distributed` keyword
  public distributed func makeMove() throws -> GameMove {
    return try ai.decideNextMove(given: &gameState)
  }

  public distributed func opponentMoved(_ move: GameMove) async throws {
    try gameState.mark(move)
  }
}

// resolving a remote actor

let sampleSystem: SampleWebSocketActorSystem

let opponentID: BotPlayer.ID = .randomID(opponentFor: self.id)
let bot = try BotPlayer.resolve(id: opponentID, using: sampleSystem) // resolve potentially remote bot playe

// Server distributed

//: [Previous](@previous) |
//: [Next](@next)
