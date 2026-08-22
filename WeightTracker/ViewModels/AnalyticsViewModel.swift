import Foundation
import Combine

final class AnalyticsViewModel: ObservableObject {
    @Published var chartData: [ChartPoint]? = []
    @Published var errorMessage: String? = ""
    @Published var weeklyDateRange: DateInterval = .init(start: .now, end: .now)
    @Published var totalWeight: Double? = 0
    @Published var averageWeight: Double? = 0
    
    func getAverage(for total: Double) -> Double {
        guard let chartData = chartData,
              !chartData.isEmpty
        else {
            return 0
        }
        
        return total / Double(chartData.count)
    }
    
    func getTotalWeight(for data: [Weight]) -> Double {
        return data.map(\.value).reduce(0, +)
    }
    
    func getDateRange(for date: Date = Date.now) {
        guard let weeklyDateRange = Calendars.getISO8601WeeklyDateRange(for: date) else {
            return
        }
        
        self.weeklyDateRange = weeklyDateRange
    }
    
    func transForm(data: [Weight]) -> [ChartPoint] {
        guard let minValue = data.map({ $0.value }).min() else { return [] }
        
        let result = data.map {
            ChartPoint(id: $0.id, date: $0.date, value: $0.value - minValue)
        }

        return result
    }
}
