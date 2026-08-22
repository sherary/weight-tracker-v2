import Foundation

struct FormatterService {
    struct Date {
        private static let formatter = DateFormatter()
        
        static let shortMonth: DateFormatter = {
            formatter.dateFormat = "MMM dd"
            
            return formatter
        }()
        
        static let longMonth: DateFormatter = {
            formatter.dateFormat = "dd MMMM"
            
            return formatter
        }()
    }
}
