import AppKit

enum DigitalDrawing {
    /// "H:MM" in 12-hour mode (hour unpadded, 12 not 0) or "HH:MM" in 24-hour mode.
    static func digits(for t: ClockTime, use24Hour: Bool) -> (text: String, meridiem: String?) {
        let mm = String(format: "%02d", t.minute)
        if use24Hour { return (String(format: "%02d:", t.hour) + mm, nil) }
        return ("\(t.hour12):\(mm)", t.isPM ? "PM" : "AM")
    }

    static func hh(_ t: ClockTime, use24Hour: Bool) -> String {
        use24Hour ? String(format: "%02d", t.hour) : "\(t.hour12)"
    }

    static func mm(_ t: ClockTime) -> String { String(format: "%02d", t.minute) }
    static func ss(_ t: ClockTime) -> String { String(format: "%02d", t.second) }

    static func font(_ size: CGFloat, weight: NSFont.Weight, rounded: Bool = false, mono: Bool = true) -> NSFont {
        let base = mono ? NSFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
                        : NSFont.systemFont(ofSize: size, weight: weight)
        if rounded, let d = base.fontDescriptor.withDesign(.rounded), let f = NSFont(descriptor: d, size: size) { return f }
        return base
    }

    /// Seven-segment glyph: bit order a(top) b(upper right) c(lower right) d(bottom) e(lower left) f(upper left) g(middle).
    static func segments(for ch: Character) -> [Bool] {
        let table: [Character: String] = [
            "0": "abcdef", "1": "bc", "2": "abdeg", "3": "abcdg", "4": "bcfg",
            "5": "acdfg", "6": "acdefg", "7": "abc", "8": "abcdefg", "9": "abcdfg",
        ]
        let on = table[ch] ?? ""
        return "abcdefg".map { on.contains($0) }
    }

    /// Draws one seven-segment digit in `cell`; `on` segments in `onColor`, off segments in `offColor`.
    static func segmentDigit(_ ctx: CGContext, cell: CGRect, ch: Character, thickness t: CGFloat,
                             onColor: CGColor, offColor: CGColor?) {
        let w = cell.width, h = cell.height, x = cell.minX, y = cell.minY
        let g = t * 0.18
        func hor(_ cy: CGFloat) -> CGRect { CGRect(x: x + t * 0.5 + g, y: cy - t / 2, width: w - t - 2 * g, height: t) }
        func ver(_ cx: CGFloat, _ y0: CGFloat) -> CGRect { CGRect(x: cx - t / 2, y: y0 + g, width: t, height: h / 2 - t - 2 * g + t * 0.5) }
        let rects: [CGRect] = [
            hor(y + h - t / 2),                       // a
            ver(x + w - t / 2, y + h / 2),            // b
            ver(x + w - t / 2, y + t * 0.0),          // c
            hor(y + t / 2),                           // d
            ver(x + t / 2, y + t * 0.0),              // e
            ver(x + t / 2, y + h / 2),                // f
            hor(y + h / 2),                           // g
        ]
        let lit = segments(for: ch)
        for (i, r) in rects.enumerated() {
            let color = lit[i] ? onColor : offColor
            guard let color else { continue }
            ctx.setFillColor(color)
            ctx.addPath(CGPath(roundedRect: r, cornerWidth: min(r.width, r.height) * 0.4,
                               cornerHeight: min(r.width, r.height) * 0.4, transform: nil))
            ctx.fillPath()
        }
    }
}
