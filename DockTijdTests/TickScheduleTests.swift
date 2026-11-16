import Testing
import Foundation
@testable import DockTijd

struct TickScheduleTests {
    typealias T = ClockTimeTests

    @Test func perSecondAdvancesToNextSecond() {
        #expect(TickSchedule.nextTick(after: T.date(10, 0, 0), perSecond: true) == T.date(10, 0, 1))
        #expect(TickSchedule.nextTick(after: T.date(10, 0, 59, ns: 999_900_000), perSecond: true) == T.date(10, 1, 0))
    }

    @Test func perMinuteIsStrictlyAfter() {
        #expect(TickSchedule.nextTick(after: T.date(10, 0, 0), perSecond: false) == T.date(10, 1, 0))
        #expect(TickSchedule.nextTick(after: T.date(10, 0, 30), perSecond: false) == T.date(10, 1, 0))
    }

    @Test func advancesAcrossDSTBoundary() {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "America/New_York")!
        let before = c.date(from: DateComponents(year: 2026, month: 3, day: 8, hour: 1, minute: 59, second: 30))!
        let next = TickSchedule.nextTick(after: before, perSecond: false, calendar: c)
        #expect(next.timeIntervalSince(before) == 30)
        #expect(c.component(.hour, from: next) == 3)
    }
}
