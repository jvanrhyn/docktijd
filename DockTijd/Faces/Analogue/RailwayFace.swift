import AppKit

/// Station-clock look: white dial, bold numerals, minute track, red second hand.
struct RailwayFace: ClockFace {
    let id = "railway"
    let name = "Railway"
    let kind = FaceKind.analogue
    let showsSeconds = true

    var cachesStaticLayer: Bool { true }

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        drawStatic(in: ctx, rect: rect, use24Hour: use24Hour)
        drawDynamic(in: ctx, rect: rect, time: time, use24Hour: use24Hour)
    }

    func drawStatic(in ctx: CGContext, rect: CGRect, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        let c = CGPoint(x: body.midX, y: body.midY)
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x202226))
        ctx.drawLinearGradient(D.gradient([D.color(0x34373C), D.color(0x17181B)]),
                               start: CGPoint(x: c.x, y: body.maxY), end: CGPoint(x: c.x, y: body.minY), options: [])
        let r = u * 0.43
        D.fillCircle(ctx, c, r, D.color(0xFAFAF8))
        D.strokeCircle(ctx, c, r, width: u * 0.016, D.color(0xCFCFCB))
        D.ticks(ctx, center: c, count: 60, from: r * 0.92, to: r * 0.97, width: u * 0.007,
                color: D.color(0x111111), skip: { $0 % 5 == 0 })
        D.ticks(ctx, center: c, count: 12, from: r * 0.90, to: r * 0.97, width: u * 0.016, color: D.color(0x111111))
        let font = NSFont.systemFont(ofSize: u * 0.085, weight: .heavy)
        D.numerals(center: c, radius: r * 0.74, font: font, color: NSColor(cgColor: D.color(0x111111))!)
        ctx.restoreGState()
    }

    func drawDynamic(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        let c = CGPoint(x: body.midX, y: body.midY)
        let r = u * 0.43
        ctx.saveGState()
        let a = D.angles(for: time)
        D.hand(ctx, center: c, angle: a.hour, length: r * 0.5, width: u * 0.045, tail: r * 0.1,
               color: D.color(0x111111), shadow: (u * 0.012, 0.25))
        D.hand(ctx, center: c, angle: a.minute, length: r * 0.82, width: u * 0.03, tail: r * 0.1,
               color: D.color(0x111111), shadow: (u * 0.012, 0.25))
        let red = D.color(0xE0281E)
        D.hand(ctx, center: c, angle: a.second, length: r * 0.88, width: u * 0.01, tail: r * 0.2, color: red)
        D.fillCircle(ctx, D.point(from: c, angle: a.second, radius: r * 0.62), u * 0.03, red)
        D.fillCircle(ctx, c, u * 0.026, red)
        ctx.restoreGState()
    }
}
