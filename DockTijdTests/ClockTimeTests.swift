import Testing
import Foundation
@testable import DockTijd

struct ClockTimeTests {
    static let cal: Calendar = {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }()

    static func date(_ h: Int, _ m: Int, _ s: Int, ns: Int = 0) -> Date {
        cal.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: h, minute: m, second: s, nanosecond: ns))!
    }

    @Test func hour12AtMidnightAndNoonIsTwelve() {
        #expect(ClockTime(date: Self.date(0, 30, 0), calendar: Self.cal).hour12 == 12)
        #expect(ClockTime(date: Self.date(12, 30, 0), calendar: Self.cal).hour12 == 12)
        #expect(ClockTime(date: Self.date(13, 0, 0), calendar: Self.cal).hour12 == 1)
    }

    @Test func isPMBoundary() {
        #expect(ClockTime(date: Self.date(11, 59, 59), calendar: Self.cal).isPM == false)
        #expect(ClockTime(date: Self.date(12, 0, 0), calendar: Self.cal).isPM == true)
    }

    @Test func readsComponentsAndFraction() {
        let t = ClockTime(date: Self.date(10, 20, 30, ns: 500_000_000), calendar: Self.cal)
        #expect(t.hour == 10 && t.minute == 20 && t.second == 30)
        #expect(abs(t.fraction - 0.5) < 0.001)
    }
}
