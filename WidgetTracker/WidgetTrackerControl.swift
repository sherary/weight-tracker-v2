import AppIntents
import SwiftUI

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
        return .result(value: delta)
    }
}
