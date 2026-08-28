import SwiftUI

struct ChartTitle: View {
    var dateRange: DateInterval
    var text: String?
    var period: DataFilter
    
    private var year: Int = 0
    
    init(dateRange: DateInterval, period: DataFilter, text: String? = nil) {
        self.dateRange = dateRange
        self.period = period
        self.year = CalendarService.ISO8601.getYear(of: dateRange.end)
        
        guard let text = text else {
            switch (period) {
            case .weekly:
                self.text = "Weight fluctuations day to day"
            case .monthly:
                self.text = "Weight fluctuations between weeks"
            case .yearly:
                self.text = "Weight fluctuations between months"
            }
            
            return
        }
        
        self.text = text
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(text ?? "-")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("\(dateRange.start, formatter: FormatterService.Date.shortMonth) - \(dateRange.end, formatter: FormatterService.Date.shortMonth)")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
                
                Text(year, format: .number.grouping(.never))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.primary)
            }
        }
    }
}
