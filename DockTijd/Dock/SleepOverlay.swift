import AppKit

/// A dim veil plus rising "Z z z", drawn over the current face as the app quits.
enum SleepOverlay {
    static func draw(in ctx: CGContext, rect: CGRect, progress: Double) {
        let p = CGFloat(min(1, max(0, progress)))
        guard p > 0 else { return }
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        ctx.saveGState()
        ctx.addPath(IconShape.path(in: rect))
        ctx.clip()
        ctx.setFillColor(CGColor(red: 0.04, green: 0.05, blue: 0.16, alpha: 0.45 * p))
        ctx.fill(body)
        ctx.restoreGState()

        let letters: [(String, CGFloat, CGPoint)] = [
            ("z", 0.10, CGPoint(x: 0.62, y: 0.60)),
            ("Z", 0.15, CGPoint(x: 0.74, y: 0.72)),
            ("Z", 0.21, CGPoint(x: 0.86, y: 0.86)),
        ]
        for (i, (s, size, pos)) in letters.enumerated() {
            // each letter fades in slightly after the previous one
            let a = min(1, max(0, p * 1.6 - CGFloat(i) * 0.3))
            guard a > 0 else { continue }
            let center = CGPoint(x: body.minX + pos.x * u, y: body.minY + pos.y * u - (1 - a) * u * 0.03)
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: u * 0.03, color: CGColor(red: 0.4, green: 0.5, blue: 1, alpha: a))
            AnalogueDrawing.text(s, at: center, font: DigitalDrawing.font(u * size, weight: .heavy, rounded: true, mono: false),
                                 color: NSColor(white: 1, alpha: a))
            ctx.restoreGState()
        }
    }
}
