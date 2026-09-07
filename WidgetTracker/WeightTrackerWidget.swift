import WidgetKit
import SwiftUI

struct WeightTrackerWidget: Widget {
    let kind: String = WidgetConfigs.kind
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: WeightTrackerWidgetConfigurationIntent.self,
            provider: WeightTrackerAppIntentTimelineProvider()
        ) { entry in
            WeightTrackerWidgetView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
