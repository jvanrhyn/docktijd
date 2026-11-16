import Testing
import Foundation
@testable import DockTijd

/// A clock that starts at a chosen wall time and then advances with real time.
final class FakeClock: @unchecked Sendable {
    private let lock = NSLock()
    private var base: Date
    private var anchor = ProcessInfo.processInfo.systemUptime
    init(start: Date) { base = start }
    func now() -> Date {
        lock.lock(); defer { lock.unlock() }
        return base.addingTimeInterval(ProcessInfo.processInfo.systemUptime - anchor)
    }
    func jump(to date: Date) {
        lock.lock(); defer { lock.unlock() }
        base = date; anchor = ProcessInfo.processInfo.systemUptime
    }
}

@MainActor
final class TickLog { var ticks: [ClockTime] = [] }

@MainActor
struct ClockEngineTests {
    typealias T = ClockTimeTests
    // Engine reads components in the current calendar, so build dates with it.
    static func local(_ h: Int, _ m: Int, _ s: Int, ns: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 10, hour: h, minute: m, second: s, nanosecond: ns))!
    }

    @Test func firesOnSecondBoundaries() async throws {
        let clock = FakeClock(start: Self.local(10, 0, 0, ns: 400_000_000))
        let log = TickLog()
        let engine = ClockEngine(now: { clock.now() }) { log.ticks.append($0) }
        engine.perSecond = true
        engine.start()
        try await Task.sleep(for: .milliseconds(1200))
        engine.stop()
        #expect(log.ticks.count == 2)           // immediate tick + one boundary
        #expect(log.ticks[1].second == 1)
        #expect(log.ticks[1].fraction < 0.1)    // fired right on the boundary
    }

    @Test func perMinuteDoesNotFireEverySecond() async throws {
        let clock = FakeClock(start: Self.local(10, 0, 10))
        let log = TickLog()
        let engine = ClockEngine(now: { clock.now() }) { log.ticks.append($0) }
        engine.perSecond = false
        engine.start()
        try await Task.sleep(for: .milliseconds(1200))
        engine.stop()
        #expect(log.ticks.count == 1)
    }

    @Test func rescheduleAfterClockChangeUsesNewNow() async throws {
        let clock = FakeClock(start: Self.local(10, 0, 0, ns: 500_000_000))
        let log = TickLog()
        let engine = ClockEngine(now: { clock.now() }) { log.ticks.append($0) }
        engine.perSecond = false
        engine.start()
        clock.jump(to: Self.local(10, 0, 58, ns: 800_000_000))
        engine.reschedule()
        try await Task.sleep(for: .milliseconds(1600))
        engine.stop()
        let last = try #require(log.ticks.last)
        #expect(last.minute == 1 && last.second == 0)
    }

    @Test func stopPreventsFurtherTicks() async throws {
        let clock = FakeClock(start: Self.local(10, 0, 0, ns: 400_000_000))
        let log = TickLog()
        let engine = ClockEngine(now: { clock.now() }) { log.ticks.append($0) }
        engine.perSecond = true
        engine.start()
        engine.stop()
        try await Task.sleep(for: .milliseconds(1300))
        #expect(log.ticks.count == 1)
    }
}
