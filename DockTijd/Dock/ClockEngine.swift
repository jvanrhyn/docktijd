import Foundation

/// Fires `onTick` on exact second (or minute) boundaries using a single one-shot timer.
/// Always reads time from `now()`, so there is no accumulated drift.
@MainActor
final class ClockEngine {
    private let now: @Sendable () -> Date
    private let onTick: (ClockTime) -> Void
    private var timer: DispatchSourceTimer?
    private var running = false

    var perSecond = false

    init(now: @escaping @Sendable () -> Date = Date.init, onTick: @escaping (ClockTime) -> Void) {
        self.now = now
        self.onTick = onTick
    }

    /// Emits a tick immediately, then on every boundary.
    func start() {
        running = true
        emitAndArm()
    }

    func stop() {
        running = false
        cancelTimer()
    }

    /// Re-arms from the current time (call after sleep/wake, clock change or perSecond change).
    func reschedule() {
        guard running else { return }
        emitAndArm()
    }

    private func cancelTimer() {
        timer?.cancel()
        timer = nil
    }

    private func emitAndArm() {
        cancelTimer()
        onTick(ClockTime(date: now()))
        arm()
    }

    private func arm() {
        let current = now()
        let next = TickSchedule.nextTick(after: current, perSecond: perSecond)
        let delay = max(0, next.timeIntervalSince(current))
        let t = DispatchSource.makeTimerSource(queue: .main)
        t.schedule(deadline: .now() + delay, leeway: .milliseconds(1))
        t.setEventHandler { [weak self] in
            MainActor.assumeIsolated {
                guard let self, self.running else { return }
                // Timers never fire early, but guard against a hair-early wake so the shown time is the boundary's.
                let n = self.now()
                let shown = max(n, next)
                self.onTick(ClockTime(date: shown))
                self.arm()
            }
        }
        timer = t
        t.resume()
    }
}
