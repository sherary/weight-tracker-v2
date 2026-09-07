import WidgetKit
import SwiftData

struct WeightTrackerWidgetEntry: TimelineEntry {
    var date: Date
    var value: Double
}

struct WeightTrackerAppIntentTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WeightTrackerWidgetEntry {
        return WeightTrackerWidgetEntry(
            date: .now,
            value: WidgetStore.value
        )
    }
    
    func snapshot(
        for configuration: WeightTrackerWidgetConfigurationIntent,
        in context: Context
    ) async -> WeightTrackerWidgetEntry {
        return WeightTrackerWidgetEntry(
            date: .now,
            value: WidgetStore.value
        )
    }
    
    func timeline(
        for configuration: WeightTrackerWidgetConfigurationIntent,
        in context: Context
    ) async -> Timeline<WeightTrackerWidgetEntry> {
        let entry = WeightTrackerWidgetEntry(
            date: .now,
            value: WidgetStore.value,
        )
        let nextMidnight = CalendarService.ISO8601.getNextMidnightTime()
        
        return Timeline(entries: [entry], policy: .after(nextMidnight))
    }
}
