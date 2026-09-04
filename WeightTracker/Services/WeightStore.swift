import SwiftUI
import SwiftData

final class WeightStore {
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.setLastRecord()
    }
    
    internal private(set) var lastRecord: Weight?
    
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
    
    internal func getOne(for dateRange: DateInterval) -> Result<Weight?, Error> {
        let startDate = dateRange.start
        let endDate = dateRange.end
        
        var descriptor = FetchDescriptor<Weight>(
            predicate: #Predicate { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        descriptor.fetchLimit = 1
        
        do {
            let data = try modelContext.fetch(descriptor)
            
            return .success(data.first)
        } catch {
            return .failure(error)
        }
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
    
    private func setLastRecord() {
        guard let dateRange = CalendarService.ISO8601.getMonthlyDateRange() else { return }
        let item = getOne(for: dateRange)
        
        switch item {
        case .success(let data):
            if let data = data {
                self.lastRecord = data
            }
        case .failure: return
        }
    }
}

