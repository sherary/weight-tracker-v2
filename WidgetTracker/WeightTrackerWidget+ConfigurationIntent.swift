import AppIntents
import SwiftData

struct WeightTrackerWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Daily Weight Tracker"
    
    @Parameter(title: "Initial Value", default: 0.0)
    var value: Double
    
    init() {
        setValue()
    }
    
    private func setValue() {
        guard let initialWeightData = getValue() else { return }
        print("initial", initialWeightData.value, initialWeightData.date)
        self.value = initialWeightData.value
        WidgetStore.set(value: value)
    }
    
    private func getValue() -> Weight? {
        let modelContext = ModelContext(PersistenceController.sharedModelContainerV2)
        let store = WeightStore(modelContext: modelContext)

        return store.lastRecord
    }
}
