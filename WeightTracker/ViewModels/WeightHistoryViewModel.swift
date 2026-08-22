//import Combine
import Foundation

@Observable
final class WeightHistoryViewModel {
    var selectedWeight: Weight?
    var weightToEdit: Weight?
    var errorMessage: String?
    var selectedFilter: DataFilter = .weekly {
        didSet {
            calculateDateRange()
        }
    }
    internal private(set) var dateRange: DateInterval = .init(start: .now, duration: 0)
    
    init() {
        calculateDateRange()
    }
    
    private func calculateDateRange() {
        if let dateRange = getDateRange() {
            setDateRange(dateRange: dateRange)
        }
    }
    
    private func getDateRange(for date: Date = Date.now) -> DateInterval? {
        switch selectedFilter {
        case .weekly: return CalendarService.ISO8601.getWeeklyDateRange(for: date)
        case .monthly: return CalendarService.ISO8601.getMonthlyDateRange(for: date)
        case .yearly: return CalendarService.ISO8601.getYearlyDateRange(for: date)
        }
    }
    
    private func setDateRange(dateRange: DateInterval) {
        self.dateRange = dateRange
    }
}
