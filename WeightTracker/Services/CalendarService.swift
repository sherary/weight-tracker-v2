import Foundation

struct CalendarService {
    struct Gregorian {
        private static var calendar = Calendar(identifier: .gregorian)
        
        internal static func getWeeklyDateRange(for date: Date = Date.now) -> DateInterval? {
            calendar.firstWeekday = 1
            
            return calendar.dateInterval(of: .weekOfYear, for: date)
        }
    }
    
    struct ISO8601 {
        private static var calendar = Calendar(identifier: .iso8601)

        init() {
            CalendarService.ISO8601.calendar.timeZone = TimeZone.current
        }
        
        internal static func getMidnightTime(for date: Date = .now) -> Date {
            guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) else { return date }
            let startOfDay = calendar.startOfDay(for: tomorrow)
            
            return startOfDay
        }
        
        internal static func getYear(of date: Date = Date.now) -> Int {
            return calendar.component(.year, from: date)
        }
        
        internal static func getWeeklyDateRange(for date: Date = Date.now) -> DateInterval? {
            guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date),
                  let weekEnd = calendar.date(byAdding: .second, value: -1, to: weekStart.end)
            else { return nil }
            
            return DateInterval(start: weekStart.start, end: weekEnd)
        }
        
        internal static func getMonthlyDateRange(for date: Date = Date.now) -> DateInterval? {
            guard let startDate = calendar.date(from: calendar.dateComponents([.year, .month], from: date)),
                  let endDate = calendar.date(byAdding: .init(month: 1, second: -1), to: startDate)
            else { return nil }
            
            return DateInterval(start: startDate, end: endDate)
        }
        
        internal static func getYearlyDateRange(for date: Date = Date.now) -> DateInterval? {
            guard let startDate = calendar.date(from: calendar.dateComponents([.year], from: date)),
                  let endDate = calendar.date(byAdding: .init(year: 1, second: -1), to: startDate)
            else { return nil }
            
            return DateInterval(start: startDate, end: endDate)
        }
    }
}
