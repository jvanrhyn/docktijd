import Foundation

enum SystemClockFormat {
    /// True when the user's locale/system setting displays 24-hour time.
    static var uses24Hour: Bool {
        let f = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: .current) ?? "HH"
        return !f.contains("a")
    }
}
