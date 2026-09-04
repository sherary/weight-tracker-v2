import SwiftData
import Foundation

enum PersistenceController {
    private static let groupId = WidgetConfigs.groupName
    
    static let sharedModelContainerV2: ModelContainer = {
        let schema = Schema([Weight.self])
        
        guard let groupURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: groupId) else {
            fatalError("App Group \(groupId) is not configured on this target")
        }
        
        let storeURL = groupURL.appending(path: "WeightTracker.store")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }()
}
