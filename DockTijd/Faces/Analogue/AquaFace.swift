import AppKit

/// Glossy blue glass dial with white hands and a specular highlight.
struct AquaFace: ClockFace {
    let id = "aqua"
    let name = "Aqua"
    let kind = FaceKind.analogue
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        let c = CGPoint(x: body.midX, y: body.midY)
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x0A5FD0))
        ctx.drawLinearGradient(D.gradient([D.color(0x4FC3FF), D.color(0x0A5FD0), D.color(0x053A8F)], [0, 0.55, 1]),
                               start: CGPoint(x: c.x, y: body.maxY), end: CGPoint(x: c.x, y: body.minY), options: [])
        let r = u * 0.43
        // glass dial
        D.radialFill(ctx, circle: c, radius: r,
                     colors: [D.color(0x7FD4FF, alpha: 0.55), D.color(0x0A4FB8, alpha: 0.85)],
                     focus: CGPoint(x: c.x, y: c.y + r * 0.3))
        D.strokeCircle(ctx, c, r, width: u * 0.014, D.color(0xFFFFFF, alpha: 0.85))
        D.strokeCircle(ctx, c, r * 0.97, width: u * 0.006, D.color(0x04307A, alpha: 0.5))
        D.ticks(ctx, center: c, count: 12, from: r * 0.82, to: r * 0.93, width: u * 0.02, color: D.color(0xFFFFFF))
        D.ticks(ctx, center: c, count: 60, from: r * 0.9, to: r * 0.93, width: u * 0.006,
                color: D.color(0xFFFFFF, alpha: 0.6), skip: { $0 % 5 == 0 })
        let a = D.angles(for: time)
        D.hand(ctx, center: c, angle: a.hour, length: r * 0.5, width: u * 0.048, tail: r * 0.06,
               color: D.color(0xFFFFFF), shadow: (u * 0.025, 0.45))
        D.hand(ctx, center: c, angle: a.minute, length: r * 0.8, width: u * 0.032, tail: r * 0.06,
               color: D.color(0xFFFFFF), shadow: (u * 0.025, 0.45))
        D.fillCircle(ctx, c, u * 0.03, D.color(0xFFFFFF))
        // specular gloss over the upper half of the dial
        ctx.saveGState()
        ctx.addPath(D.circlePath(c, r * 0.97))
        ctx.clip()
        let gloss = CGPath(ellipseIn: CGRect(x: c.x - r * 0.9, y: c.y + r * 0.05, width: r * 1.8, height: r * 1.3), transform: nil)
        ctx.addPath(gloss)
        ctx.clip()
        ctx.drawLinearGradient(D.gradient([D.color(0xFFFFFF, alpha: 0.5), D.color(0xFFFFFF, alpha: 0.02)]),
                               start: CGPoint(x: c.x, y: c.y + r), end: CGPoint(x: c.x, y: c.y + r * 0.05), options: [])
        ctx.restoreGState()
        ctx.restoreGState()
    }
}
