import AppIntents

struct WeightTrackerWidgetConfiguration: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Weight Tracker Configuration Intent"
    static let description: IntentDescription = IntentDescription("Choose step size")
    
    @Parameter(title: "Step size", default: 0.1)
    var step: Double
}
