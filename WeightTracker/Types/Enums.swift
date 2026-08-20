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
