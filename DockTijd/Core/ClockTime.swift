import Foundation

struct ClockTime: Equatable, Sendable {
    let hour: Int
    let minute: Int
    let second: Int
    /// Sub-second part, 0..<1.
    let fraction: Double

    init(hour: Int, minute: Int, second: Int, fraction: Double = 0) {
        self.hour = hour
        self.minute = minute
        self.second = second
        self.fraction = fraction
    }

    init(date: Date, calendar: Calendar = .current) {
        let c = calendar.dateComponents([.hour, .minute, .second, .nanosecond], from: date)
        self.init(hour: c.hour ?? 0, minute: c.minute ?? 0, second: c.second ?? 0,
                  fraction: Double(c.nanosecond ?? 0) / 1_000_000_000)
    }

    /// 1...12
    var hour12: Int { hour % 12 == 0 ? 12 : hour % 12 }
    var isPM: Bool { hour >= 12 }
}
