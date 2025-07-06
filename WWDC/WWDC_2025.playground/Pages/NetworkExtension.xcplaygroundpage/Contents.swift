import Foundation

/*:
 # Filter and tunnel network traffic with NetworkExtension

 [WWDC video](https://developer.apple.com/videos/play/wwdc2025/234)
*/

/*:
## Key Points
 - Access remote resources
 - New on iOS/macOS/iPadOS 26
 - Capabilities
  - Hotspot interaction
  - Local push server support
    - Text-message and voice IP calls on restricted network
  - DNS configuration and proxies
  - macOS: Transparent proxies
  - Secure remote resources
  - Content filters
*/

//NEHotspotHelper // Xcode 26

// MARK: - Secure remote access

// Network relays
  // Tunnel TCP or UDP traffic for apps
  // Great for enterprise apps
  // MASQUE protocol
  // No app extension required
    // NERelayManager
// IP-based VPN
  //
// Filter APIs
  // URL filtering
    // allows to inspect all components of URLs
  // for: Parental Control, Education, etc

//: [Previous](@previous) |
//: [Next](@next)
