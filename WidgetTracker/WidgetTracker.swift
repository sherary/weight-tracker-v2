import WidgetKit
import AppIntents
import SwiftUI
import SwiftData

struct WeightTrackerWidgetView : View {
    var entry: WeightTrackerWidgetEntry

    var body: some View {
        if entry.size == .systemMedium {
            VStack(alignment: .center) {
                Text("Add new record for today's weight")
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .center) {
                    Button(intent: AdjustWeightIntent(delta: -0.1)) {
                        Image(systemName: "minus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16, alignment: .center)
                    }
                    
                    Text(entry.value, format: .number.precision(.fractionLength(2)))
                        .font(.title)
                        .foregroundStyle(.primary)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray, lineWidth: 1)
                        )
                    
                    Button(intent: AdjustWeightIntent(delta: 0.1)) {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16, alignment: .center)
                    }
                }
                
                Text("kg")
            }
            .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

struct WeightTrackerWidgetEntry: TimelineEntry {
    var date: Date
    var value: Double
    var size: WidgetFamily? = .systemMedium
}

struct WeightTrackerTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> WeightTrackerWidgetEntry {
        WeightTrackerWidgetEntry(date: .now, value: 0)
    }
    
    func snapshot(for configuration: WeightTrackerWidgetConfiguration, in context: Context) async -> WeightTrackerWidgetEntry {
        WeightTrackerWidgetEntry(date: .now, value: 0.5)
    }
    
    func timeline(for configuration: WeightTrackerWidgetConfiguration, in context: Context) async -> Timeline<WeightTrackerWidgetEntry> {
        let modelContext = ModelContext(PersistenceController.sharedModelContainerV2)
        let store = WeightStore(modelContext: modelContext)
        var entry = WeightTrackerWidgetEntry(date: .now, value: 0)
        if let lastWeight = store.lastRecord {
            entry.date = .now
            entry.value = lastWeight.value
        }
        
        let midnight = CalendarService.ISO8601.getMidnightTime(for: .now)
        return Timeline(entries: [entry], policy: .after(midnight))
    }
}

struct WeightTrackerWidget: Widget {
    let kind: String = "WeightTrackerWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: WeightTrackerWidgetConfiguration.self,
            provider: WeightTrackerTimelineProvider()
        ) {
            entry in
            WeightTrackerWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    WeightTrackerWidget()
} timeline: {
    WeightTrackerWidgetEntry(date: .now, value: 56.5)
    WeightTrackerWidgetEntry(date: .now, value: 56.1)
}
