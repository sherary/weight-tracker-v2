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
