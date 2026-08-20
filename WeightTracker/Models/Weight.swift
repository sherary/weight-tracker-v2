import SwiftUI
import SwiftData

@Model
final class Weight {
    @Attribute(.unique) var id: UUID = UUID()
    var value: Double = 0
    @Attribute(.unique) var date: Date = Date.now
    
    init(id: UUID = UUID(), value: Double = 0, date: Date = .now) {
        self.id = id
        self.value = value
        self.date = Calendar.current.startOfDay(for: date)
    }
}
