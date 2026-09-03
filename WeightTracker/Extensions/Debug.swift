import SwiftData
import Foundation

#if DEBUG && targetEnvironment(simulator)
extension ModelContext {
    func deleteAllWeights() {
        do {
            try delete(model: Weight.self)
            try save()
        } catch {
            print("delete failed:", error)
        }
    }

    func seedYearOfWeights() {
        let calendar = Calendar.current
        var value = 55.0
        
        var dateComponent = DateComponents()
        dateComponent.year = 2027
        dateComponent.month = 1
        dateComponent.day = 1
        
        guard let date = calendar.date(from: dateComponent) else { return }
        guard let endDate = calendar.date(byAdding: .second, value: -1, to: date) else { return }
        
        for offset in 0..<365 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: endDate) else { continue }
            
            value += Double.random(in: -0.4...0.4)
            let weight = Weight(value: (value * 10).rounded() / 10,
                                date: calendar.startOfDay(for: date))
            
            insert(weight)
        }
        
        do {
            try save()
        } catch {
            print("insert failed:", error)
        }
    }
}
#endif
