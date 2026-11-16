import Foundation

enum TickSchedule {
    /// The next exact second (or minute) boundary strictly after `date`.
    static func nextTick(after date: Date, perSecond: Bool, calendar: Calendar = .current) -> Date {
        if perSecond {
            let floored = floor(date.timeIntervalSinceReferenceDate)
            return Date(timeIntervalSinceReferenceDate: floored + 1)
        }
        let c = calendar.dateComponents([.second, .nanosecond], from: date)
        let elapsed = Double(c.second ?? 0) + Double(c.nanosecond ?? 0) / 1_000_000_000
        return date.addingTimeInterval(60 - elapsed)
    }
}
