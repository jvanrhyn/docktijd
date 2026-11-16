import AppKit

/// White dial, black hands, ticks only.
struct ClassicFace: ClockFace {
    let id = "classic"
    let name = "Classic"
    let kind = FaceKind.analogue
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        let c = CGPoint(x: body.midX, y: body.midY)
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0xE9E7E2))
        // soft paper gradient on the body
        ctx.drawLinearGradient(D.gradient([D.color(0xFBFAF7), D.color(0xE3E0D9)]),
                               start: CGPoint(x: c.x, y: body.maxY), end: CGPoint(x: c.x, y: body.minY), options: [])
        // dial
        let r = u * 0.43
        D.strokeCircle(ctx, c, r, width: u * 0.012, D.color(0x1B1B1D))
        D.ticks(ctx, center: c, count: 60, from: r * 0.93, to: r * 0.97, width: u * 0.006,
                color: D.color(0x1B1B1D, alpha: 0.7), skip: { $0 % 5 == 0 })
        D.ticks(ctx, center: c, count: 12, from: r * 0.82, to: r * 0.97, width: u * 0.022, color: D.color(0x1B1B1D))
        let a = D.angles(for: time)
        D.hand(ctx, center: c, angle: a.hour, length: r * 0.52, width: u * 0.04, tail: r * 0.08,
               color: D.color(0x1B1B1D), shadow: (u * 0.012, 0.3))
        D.hand(ctx, center: c, angle: a.minute, length: r * 0.82, width: u * 0.026, tail: r * 0.1,
               color: D.color(0x1B1B1D), shadow: (u * 0.012, 0.3))
        D.fillCircle(ctx, c, u * 0.028, D.color(0x1B1B1D))
        D.fillCircle(ctx, c, u * 0.010, D.color(0xE9E7E2))
        ctx.restoreGState()
    }
}
