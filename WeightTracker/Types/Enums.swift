import Foundation

enum HistoryDestination: Identifiable {
    case add
    case edit(Weight)
    
    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let item): return item.id.uuidString
        }
    }
}

enum AlertType {
    case delete
    case choice(String)
    
    var confirmButtonText: String {
        switch self {
        case .delete: return "Delete"
        case .choice(let text): return text.isEmpty ? "Yes" : text
        }
    }
    
    var cancelButtonText: String {
        switch self {
        case .delete: return "Cancel"
        case .choice: return "No"
        }
    }
}

enum DataFilter: Int, CaseIterable {
    case weekly = 0, monthly, yearly
    
    var title: String {
        switch self {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        }
    }
    
    var value: Int {
        return self.rawValue
    }
}
