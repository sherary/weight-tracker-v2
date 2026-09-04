import WidgetKit
import AppIntents
import SwiftUI
import SwiftData

struct WeightTrackerWidgetView : View {
    var entry: WeightTrackerWidgetEntry
    @Environment(\.widgetFamily) private var widgetFamily

    var body: some View {
        Group {
            if widgetFamily == .systemMedium {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        Text("Daily Weight Tracker")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        
                        Text(entry.date, formatter: FormatterService.Date.widgetShort)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.primary)
                        
                        
                        Spacer()
                    }
                    
                    Spacer()
                    
                    VStack {
                        HStack {
                            Text(entry.value, format: .number.precision(.fractionLength(2)))
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.primary)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.gray, lineWidth: 1)
                                )
                        }
                        
                        HStack(alignment: .center, spacing: 8) {
                            Button(intent: AdjustWeightIntent(delta: -0.1)) {
                                Image(systemName: "minus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                            .buttonStyle(.borderless)
                            
                            Spacer()

                            Button(intent: AdjustWeightIntent(delta: 0.1)) {
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 16, height: 16)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                    }
                    
                    Text("kg")
                        .foregroundStyle(.secondary)
                        .font(.body)
                }
            } else {
                HStack(alignment: .center) {
                    VStack(alignment: .leading) {
                        HStack(alignment: .center) {
                            Text(entry.date, formatter: FormatterService.Date.shortMonth)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Text(entry.date, format: .dateTime.year())
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                        }
                        
                        HStack(alignment: .center) {
                            Text(entry.value, format: .number.precision(.fractionLength(2)))
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.gray, lineWidth: 1)
                                )
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.primary)
                            
                            Text("kg")
                                .foregroundStyle(.secondary)
                                .font(.body)
                        }
                        .padding(.vertical, 12)
                        
                        Text("Daily Weight Tracker")
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(1)
                            .font(.system(size: 8, weight: .semibold))
                    }
                    
                    VStack(alignment: .center, spacing: 32) {
                        Button(intent: AdjustWeightIntent(delta: -0.1)) {
                            Image(systemName: "chevron.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.borderless)
                        
                        Spacer()

                        Button(intent: AdjustWeightIntent(delta: 0.1)) {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                        .buttonStyle(.borderless)
                    }
                }
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct WeightTrackerWidgetEntry: TimelineEntry {
    var date: Date
    var value: Double
}

struct WeightTrackerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeightTrackerWidgetEntry {
        WeightTrackerWidgetEntry(date: .now, value: 0)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let entry = WeightTrackerWidgetEntry(date: .now, value: WidgetStore.value)
        
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeightTrackerWidgetEntry>) -> Void) {
        let entry = WeightTrackerWidgetEntry(date: .now, value: WidgetStore.value)
        
        let timeline = Timeline(
            entries: [entry],
            policy: .never
        )
        
        completion(timeline)
    }
}

struct WeightTrackerWidget: Widget {
    let kind: String = WidgetConfigs.kind
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: WeightTrackerTimelineProvider()
        ) { entry in
            WeightTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName("Weight Tracker Widget")
        .description("Daily record of your weight")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemMedium) {
    WeightTrackerWidget()
} timeline: {
    WeightTrackerWidgetEntry(date: .now, value: 56.5)
    WeightTrackerWidgetEntry(date: .now, value: 56.1)
}
