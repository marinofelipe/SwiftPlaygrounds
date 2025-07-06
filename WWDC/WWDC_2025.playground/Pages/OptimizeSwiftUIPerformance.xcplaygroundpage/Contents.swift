/*:
 # Optimize SwiftUI Performance with Instruments
 ## WWDC 2025 - Session 306
 
 [WWDC video](https://developer.apple.com/videos/play/wwdc2025/306)
 
 ### Key Topics:
 - SwiftUI Performance Profiling
 - Identifying and Resolving Performance Bottlenecks
 - Understanding SwiftUI Update Mechanisms
 
 ### Main Concepts:
 - New SwiftUI Instrument in Instruments 26
 - Diagnosing Long View Body Updates
 - Cause and Effect of SwiftUI View Updates
 - Optimizing Data Dependencies
 
 ---
 
 ## Performance Profiling Techniques
 
 Use Instruments 26 SwiftUI template to:
 - Analyze "Update Groups" lane
 - Identify long view body updates
 - Use Time Profiler to examine CPU usage
 
 ---
 
 ## View Body Update Optimization Example
 
 ### Before: Inefficient distance calculation
 */

import SwiftUI
import CoreLocation

// Example of inefficient approach - recreating formatter in view body
struct LandmarkRowInefficient: View {
    let landmark: Landmark
    @State private var currentLocation: CLLocation?
    
    private var distance: String? {
        guard let currentLocation = currentLocation else { return nil }
        let distance = currentLocation.distance(from: landmark.clLocation)
        
        // ❌ Expensive formatter creation in view body
        let formatter = MeasurementFormatter()
        return formatter.string(from: Measurement(value: distance, unit: UnitLength.meters))
    }
    
    var body: some View {
        HStack {
            Text(landmark.name)
            Spacer()
            if let distance = distance {
                Text(distance)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/*:
 ### After: Cached distance strings
 */

// Example of optimized approach - pre-calculated distance strings
@Observable
class LocationModel {
    var currentLocation: CLLocation?
    var distanceCache: [String: String] = [:]
    
    private let formatter = MeasurementFormatter()
    
    func updateDistances(for landmarks: [Landmark]) {
        guard let currentLocation else { return }
        
        // ✅ Populate cache with pre-calculated distance strings
        self.distanceCache = landmarks.reduce(into: [:]) { result, landmark in
            let distance = self.formatter.string(
                from: Measurement(
                    value: currentLocation.distance(from: landmark.clLocation),
                    unit: UnitLength.meters
                )
            )
            result[landmark.id] = distance
        }
    }
}

struct LandmarkRowOptimized: View {
    let landmark: Landmark
    @Environment(LocationModel.self) private var locationModel
    
    var body: some View {
        HStack {
            Text(landmark.name)
            Spacer()
            if let distance = locationModel.distanceCache[landmark.id] {
                Text(distance)
                    .foregroundColor(.secondary)
            }
        }
    }
}

/*:
 ## Reducing Unnecessary View Updates
 
 ### Key Strategies:
 - Use granular view models
 - Minimize dependencies on large data collections
 - Leverage @Observable macro strategically
 */

// Example: Granular view model to reduce updates
@Observable
class LandmarkDetailModel {
    var landmark: Landmark
    var isFavorite: Bool
    
    init(landmark: Landmark) {
        self.landmark = landmark
        self.isFavorite = landmark.isFavorite
    }
    
    func toggleFavorite() {
        isFavorite.toggle()
        // Update only the specific property needed
    }
}

struct LandmarkDetailView: View {
    @State private var model: LandmarkDetailModel
    
    init(landmark: Landmark) {
        self.model = LandmarkDetailModel(landmark: landmark)
    }
    
    var body: some View {
        VStack {
            Text(model.landmark.name)
                .font(.largeTitle)
            
            Button(action: model.toggleFavorite) {
                Image(systemName: model.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(model.isFavorite ? .red : .gray)
            }
        }
    }
}

/*:
 ## Sample Data for Testing
 */

struct Landmark {
    let id: String
    let name: String
    let coordinate: CLLocationCoordinate2D
    let isFavorite: Bool
    
    var clLocation: CLLocation {
        CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

// Sample landmarks for testing
let sampleLandmarks = [
    Landmark(id: "1", name: "Golden Gate Bridge", coordinate: CLLocationCoordinate2D(latitude: 37.8199, longitude: -122.4783), isFavorite: false),
    Landmark(id: "2", name: "Alcatraz Island", coordinate: CLLocationCoordinate2D(latitude: 37.8267, longitude: -122.4230), isFavorite: true),
    Landmark(id: "3", name: "Fisherman's Wharf", coordinate: CLLocationCoordinate2D(latitude: 37.8080, longitude: -122.4177), isFavorite: false)
]

/*:
 ## Key Takeaways
 
 ### Performance Optimization Principles:
 1. **Ensure view bodies update quickly** - Avoid expensive operations in computed properties
 2. **Update only when needed** - Use granular data models to minimize unnecessary updates
 3. **Cache expensive calculations** - Pre-calculate and store results when possible
 4. **Use Instruments effectively** - Profile with SwiftUI Instrument to identify bottlenecks
 
 ### Recommended Tools:
 - Xcode 26
 - Instruments 26
 - SwiftUI Instrument
 - Time Profiler
 
 ---
 
 **Key Quote**: "Ensure your view bodies update quickly and only when needed to achieve great SwiftUI performance."
 
 [Previous: What's New in SwiftUI](@previous) | [Next: Building Rich Text Editing Experiences](@next)
 */