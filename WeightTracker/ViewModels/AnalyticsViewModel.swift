import Foundation
import Combine

@Observable
final class AnalyticsViewModel {
    var chartPoints: [ChartPoint]?
    var errorMessage: String?
    var totalWeight: Double? = 0
    var averageWeight: Double? = 0
    var period: Period = .weekly {
        didSet {
            calculateDateRange()
        }
    }
    internal private(set) var dateRange: DateInterval = .init(start: .now, duration: 0)
    internal private(set) var weights: [Weight]? {
        didSet {
            if let weights = weights, !weights.isEmpty {
                setChartPoints(with: weights)
                setTotalWeight(from: weights)
                setAverageWeight(from: totalWeight ?? 0, weights: weights)
            }
        }
    }
    
    init() {
        calculateDateRange()
    }
    
    func setWeights(with data: [Weight]) {
        self.weights = data
    }
    
    private func calculateDateRange() {
        if let dateRange = getDateRange() {
            setDateRange(dateRange: dateRange)
        }
    }
    
    private func getDateRange(for date: Date = Date.now) -> DateInterval? {
        switch period {
        case .weekly: return CalendarService.ISO8601.getWeeklyDateRange(for: date)
        case .monthly: return CalendarService.ISO8601.getMonthlyDateRange(for: date)
        case .yearly: return CalendarService.ISO8601.getYearlyDateRange(for: date)
        }
    }
    
    private func setDateRange(dateRange: DateInterval) {
        self.dateRange = dateRange
    }
    
    private func setAverageWeight(from total: Double, weights: [Weight]) {
        switch period {
        case .weekly:
            self.averageWeight = getAverage(for: total, denominator: weights.count)
        case .monthly:
            self.averageWeight = getAverage(for: total, denominator: weights.count)
        case .yearly:
            self.averageWeight = getAverage(for: total, denominator: weights.count)
        }
    }
    
    private func getAverage(for total: Double, denominator: Int) -> Double {
        return total / Double(denominator)
    }
    
    private func setTotalWeight(from data: [Weight]) {
        self.totalWeight = getTotalWeight(for: data)
    }
    
    private func getTotalWeight(for data: [Weight]) -> Double {
        return data.map(\.value).reduce(0, +)
    }
    
    private func setChartPoints(with data: [Weight]) {
        switch period {
        case .weekly:
            self.chartPoints = transForm(data: data)
        case .monthly:
            self.chartPoints = transformMonthly(weights: data)
        case .yearly:
            self.chartPoints = transformYearly(weights: data)
        }
    }
    
    private func transformYearly(weights: [Weight]) -> [ChartPoint] {
        guard let minValue = weights.map({ $0.value }).min() else { return [] }
        guard let dateCutOff = weights.map({ $0.date }).max() else { return [] }
        
        var result: [ChartPoint] = []
        
        let calendar = Calendar.current
        let targetYear = CalendarService.ISO8601.getYear(of: dateCutOff)
        let yearComponents = DateComponents(year: targetYear)
        
        if let yearStartDate = calendar.date(from: yearComponents),
           let yearInterval = calendar.dateInterval(of: .year, for: yearStartDate) {
            var currentMonthStart = yearInterval.start
            
            while currentMonthStart < yearInterval.end {
                if let monthInterval = calendar.dateInterval(of: .month, for: currentMonthStart) {
                    let monthNumber = calendar.component(.month, from: monthInterval.start)
                    let startDate = monthInterval.start
                    let endDate = monthInterval.end
                    
                    let filteredData = weights.filter { $0.date >= startDate && $0.date < endDate }
                    let total = filteredData.map(\.value).reduce(0, +)
                    let average = total / Double(filteredData.count)
                    
                    let point = ChartPoint(id: UUID(), label: "\(monthNumber)", value: average - minValue)
                    result.append(point)
                    
                    currentMonthStart = endDate
                } else {
                    break
                }
            }
        }
        
        return result
    }
    
    private func transformMonthly(weights: [Weight]) -> [ChartPoint] {
        guard let minValue = weights.map({ $0.value }).min() else { return [] }
        
        var result: [ChartPoint] = []
        var startDate = dateRange.start
        var index: Int = 0
        
        while startDate < dateRange.end {
            guard let midDate = Calendar.current.date(byAdding: .day, value: 7, to: startDate) else { break }
            let filteredData = weights.filter { $0.date >= startDate && $0.date < midDate }
            let total = filteredData.map(\.value).reduce(0, +)
            let average = total / Double(filteredData.count)
            
            index += 1
            
            let point = ChartPoint(id: UUID(), label: "Week \(index)", value: average - minValue)
            result.append(point)
            
            startDate = midDate
        }
        
        return result
    }
    
    private func transForm(data: [Weight]) -> [ChartPoint] {
        guard let minValue = data.map({ $0.value }).min() else { return [] }
        var result: [ChartPoint] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM"
        
        for item in data {
            let label = dateFormatter.string(from: item.date)
            let item = ChartPoint(id: item.id, label: label, value: item.value - minValue)
            
            result.append(item)
        }
        
        return result
    }
}
