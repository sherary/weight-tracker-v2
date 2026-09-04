import WidgetKit
import SwiftData
import SwiftUI
import AppIntents

struct AdjustWeightIntent: AppIntent {
    static let title: LocalizedStringResource = "Adjust Weight"
    
    @Parameter(title: "Delta")
    var delta: Double
    
    init() {
        self.delta = 0
    }
    
    init(delta: Double) {
        self.delta = delta
    }
    
    func perform() async throws -> some IntentResult {
        var compoundingValue: Double = WidgetStore.value
        compoundingValue += self.delta
        
        let modelContext = ModelContext(PersistenceController.sharedModelContainerV2)
        let weightStore = WeightStore(modelContext: modelContext)
        let data = Weight(value: compoundingValue, date: .now)
        weightStore.upsert(data: data)
        
        WidgetStore.set(value: compoundingValue)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConfigs.kind)
        
        return .result()
    }
}
