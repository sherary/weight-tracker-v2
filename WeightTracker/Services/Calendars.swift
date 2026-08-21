import Foundation

struct Calendars {
    internal static func getGregorianWeeklyDateRange(for date: Date = Date()) -> DateInterval? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 1
        
        return calendar.dateInterval(of: .weekOfYear, for: date)
    }
    
    internal static func getISO8601WeeklyDateRange(for date: Date = Date()) -> DateInterval? {
        var calendar = Calendar(identifier: .iso8601)
        calendar.timeZone = TimeZone.current
        
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date),
              let inclusiveEnd = calendar.date(byAdding: .second, value: -1, to: interval.end)
        else { return nil }

        return DateInterval(start: interval.start, end: inclusiveEnd)
    }
}
