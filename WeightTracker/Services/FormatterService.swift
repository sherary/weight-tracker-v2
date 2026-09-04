import Foundation

struct FormatterService {
    struct Date {
        private static let formatter = DateFormatter()
        
        init() {
            FormatterService.Date.formatter.locale = Locale(identifier: "id_ID")
        }
        
        static let shortMonth: DateFormatter = {
            formatter.dateFormat = "MMM dd"
            
            return formatter
        }()
        
        static let longMonth: DateFormatter = {
            formatter.dateFormat = "dd MMMM"
            
            return formatter
        }()
        
        static let widgetShort: DateFormatter = {
            formatter.dateFormat = "MMM dd - YYYY"
            
            return formatter
        }()
    }
}
