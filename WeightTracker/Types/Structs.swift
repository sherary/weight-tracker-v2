import Foundation

struct ChartPoint: Identifiable {
    let id: UUID
    let label: String
    let value: Double
}

struct AxisLabels {
    static let x = AxisLabelX.week
    static let y = AxisLabelY.weight
}

enum AxisLabelX: String {
    case week, month, year

    var description: String {
        switch self {
        case .week: return "Date"
        case .month: return "Week"
        case .year: return "Month"
        }
    }
}

enum AxisLabelY: String {
    case weight
    
    var description: String {
        switch self {
        case .weight: return "Weight"
        }
    }
}
