/*:
 # Use structured concurrency with Network framework
 [WWDC video](https://developer.apple.com/videos/play/wwdc2025/250)

 ### Key Topics:
 - TLS secure by default
 - Supports proxy, etc
  - WebSocket, TLS, TCP, IP
  - WebSocket, Quick, UDP, IP
 - iOS/macOS 26 goes Concurrency first on Networking
 -

 ### Main Concepts:
 - NetworkConnection type
  - Protocol, i.e. TLS
  - url
  - port
 - Useful for when using connections that are not HTTP based, otherwise URLSession is still the go to

 ---

 ## NetworkConnection API

 */

// Make a connection

import Network

var connection = NetworkConnection(to: .hostPort(host: "www.example.com", port: 1029)) {
  TLS()
}

/*:
 ### After: Constrained and without fragmentation
 */

// Make a connection

connection = NetworkConnection(
  to: .hostPort(host: "www.example.com", port: 1029),
  using: .parameters {
    TLS {
      TCP {
        IP()
          .fragmentationEnabled(false)
      }
    }
  }
  .constrainedPathsProhibited(true)
)

// Send and receive on a connection

public func sendAndReceiveWithTLS() async throws {
  let connection = NetworkConnection(to: .hostPort(host: "www.example.com", port: 1029)) {
    TLS()
  }

  let outgoingData = Data("Hello, world!".utf8)
  try await connection.send(outgoingData)

  let incomingData = try await connection.receive(exactly: 98).content
  print("Received data: \(incomingData)")
}

// Send and receive on a connection

public func sendAndReceiveWithTLS2() async throws {
  let connection = NetworkConnection(to: .hostPort(host: "www.example.com", port: 1029)) {
    TLS()
  }

  let outgoingData = Data("Hello, world!".utf8)
  try await connection.send(outgoingData)

  let remaining32 = try await connection.receive(as: UInt32.self).content
  guard var remaining = Int(exactly: remaining32) else { /* ... throw an error ... */ }
  while remaining > 0 {
    let imageChunk = try await connection.receive(atLeast: 1, atMost: remaining).content
    remaining -= imageChunk.count

    // Parse the next portion of the image before continuing
  }
}

// Receive TicTacToe game messages with Coder

import Network

public func receiveWithCoder() async throws {
  let connection = NetworkConnection(to: .hostPort(host: "www.example.com", port: 1029)) {
    Coder(GameMessage.self, using: .json) {
      TLS()
    }
  }

  let gameMessage = try await connection.receive().content
  switch gameMessage {
  case .selectedCharacter(let character):
    print("Character selected: \(character)")
  case .move(let row, let column):
    print("Move: (\(row), \(column))")
  }
}

// Listen for incoming connections with NetworkListener

import Network

public func listenForIncomingConnections() async throws {
  try await NetworkListener {
    Coder(GameMessage.self, using: .json) {
      TLS()
    }
  }.run { connection in
    for try await (gameMessage, _) in connection.messages {
      // Handle the GameMessage
    }
  }
}

// Browse for nearby paired Wi-Fi Aware devices

import Network
import WiFiAware

public func findNearbyDevice() async throws {
  let endpoint = try await NetworkBrowser(for: .wifiAware(.connecting(to: .allPairedDevices, from: .ticTacToeService))).run { endpoints in
    .finish(endpoints.first!)
  }

  // Make a connection to the endpoint
}

// WIFI goodies
// - Peer-to-peer
// - Stay connected to internet
// - Wi-fi Alliance standard

/*:
 [Previous](@previous) | [Next](@next)
 */
