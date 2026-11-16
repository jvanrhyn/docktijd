import AppKit

/// Near-black dial, no numerals, bold white hands, orange accent.
struct MinimalDarkFace: ClockFace {
    let id = "minimalDark"
    let name = "Minimal Dark"
    let kind = FaceKind.analogue
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        let c = CGPoint(x: body.midX, y: body.midY)
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x111113))
        ctx.drawLinearGradient(D.gradient([D.color(0x2A2A2E), D.color(0x0B0B0D)]),
                               start: CGPoint(x: c.x, y: body.maxY), end: CGPoint(x: c.x, y: body.minY), options: [])
        let r = u * 0.43
        for i in [0, 3, 6, 9] {
            let ang = CGFloat(i) / 12 * 2 * .pi
            D.fillCircle(ctx, D.point(from: c, angle: ang, radius: r * 0.9), u * 0.016, D.color(0xFFFFFF, alpha: 0.85))
        }
        D.ticks(ctx, center: c, count: 12, from: r * 0.86, to: r * 0.92, width: u * 0.008,
                color: D.color(0xFFFFFF, alpha: 0.35), skip: { $0 % 3 == 0 })
        let a = D.angles(for: time)
        D.hand(ctx, center: c, angle: a.hour, length: r * 0.5, width: u * 0.055, tail: r * 0.05,
               color: D.color(0xF4F4F6), shadow: (u * 0.02, 0.5))
        D.hand(ctx, center: c, angle: a.minute, length: r * 0.78, width: u * 0.04, tail: r * 0.05,
               color: D.color(0xF4F4F6), shadow: (u * 0.02, 0.5))
        D.fillCircle(ctx, c, u * 0.032, D.color(0xFF7A1A))
        D.fillCircle(ctx, c, u * 0.012, D.color(0x111113))
        ctx.restoreGState()
    }
}
