import AppKit

final class ClockView: NSView {
    var face: any ClockFace = ClassicFace() { didSet { needsDisplay = true } }
    var time = ClockTime(hour: 10, minute: 10, second: 0) { didSet { needsDisplay = true } }
    var use24Hour = SystemClockFormat.uses24Hour { didSet { needsDisplay = true } }

    /// 0 = awake, 1 = fully asleep (used while quitting).
    var sleepProgress: Double = 0 { didSet { needsDisplay = true } }

    private let layerCache = StaticLayerCache()

    override var isFlipped: Bool { false }
    override var isOpaque: Bool { false }

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        if face.cachesStaticLayer {
            let scale = window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2
            ctx.draw(layerCache.image(for: face, size: bounds.size, scale: scale, use24Hour: use24Hour), in: bounds)
            face.drawDynamic(in: ctx, rect: bounds, time: time, use24Hour: use24Hour)
        } else {
            face.draw(in: ctx, rect: bounds, time: time, use24Hour: use24Hour)
        }
        SleepOverlay.draw(in: ctx, rect: bounds, progress: sleepProgress)
    }
}
