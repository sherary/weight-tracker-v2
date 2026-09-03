import SwiftUI
import SwiftData

@main
struct WeightTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(PersistenceController.sharedModelContainerV2)
    }
}
