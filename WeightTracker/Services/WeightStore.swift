import SwiftUI
import SwiftData

final class WeightStore {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    internal var lastRecord: Weight? {
        return getAvailable()
    }
    
    internal func getItems(dateRange: DateInterval) -> Result<[Weight]?, Error> {
        let startDate = dateRange.start
        let endDate = dateRange.end
        
        let descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date)]
        )
        
        do {
            let data = try modelContext.fetch(descriptor)
            
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
    
    internal func getAvailable(by period: RecursiveFetch = .today) -> Weight {
        var date = Date()
        var dateRange = DateInterval()
        
        switch period {
        case .today:
            if let dailyRange = CalendarService.ISO8601.getDailyDateRange(for: date) {
                dateRange = dailyRange
            }
            
            guard let item = getWeight(by: dateRange) else {
                return getAvailable(by: .yesterday)
            }
            
            return item
        case .yesterday:
            if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: date) {
                date = yesterday
            }
            
            if let dailyRange = CalendarService.ISO8601.getDailyDateRange(for: date) {
                dateRange = dailyRange
            }
            
            guard let item = getWeight(by: dateRange) else {
                return getAvailable(by: .yesterday)
            }
            
            return item
        case .thisWeek:
            if let weeklyRange = CalendarService.ISO8601.getWeeklyDateRange(for: date) {
                dateRange = weeklyRange
            }
            
            guard let item = getWeight(by: dateRange) else {
                return getAvailable(by: .thisMonth)
            }
            
            return item
        case .thisMonth:
            if let monthlyRange = CalendarService.ISO8601.getMonthlyDateRange(for: date) {
                dateRange = monthlyRange
            }
            
            guard let item = getWeight(by: dateRange) else {
                return getAvailable(by: .thisYear)
            }
            
            return item
        case .thisYear:
            if let yearlyRange = CalendarService.ISO8601.getYearlyDateRange(for: date) {
                dateRange = yearlyRange
            }
            
            guard let item = getWeight(by: dateRange) else {
                return AppConfigs.initialData
            }
            
            return item
        }
    }
    
    internal func getWeight(by dateRange: DateInterval) -> Weight? {
        return try? fetchWeight(from: dateRange.start, to: dateRange.end)
    }
    
    internal func fetchWeight(from startDate: Date, to endDate: Date) throws -> Weight? {
        var descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate<Weight> { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        descriptor.fetchLimit = 1
        
        return try modelContext.fetch(descriptor).first
    }
    
    internal func upsert(data: Weight) {
        let targetDate = Calendar.current.startOfDay(for: data.date)
        var descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate { $0.date == targetDate }
        )
        descriptor.fetchLimit = 1
        
        do {
            let fetchItem = try modelContext.fetch(descriptor)
            if let existingData = fetchItem.first {
                existingData.value = data.value
            } else {
                modelContext.insert(data)
            }
            
           try modelContext.save()
        } catch {
            print(error.localizedDescription)
            
            modelContext.rollback()
        }
    }
    
    internal func insert(data: Weight) {
        modelContext.insert(data)
    }
    
    internal func commit() -> String? {
        do {
            try modelContext.save()
            
            return nil
        } catch {
            modelContext.rollback()
            return error.localizedDescription
        }
    }
    
    internal func delete(data: Weight) {
        modelContext.delete(data)
    }
}

