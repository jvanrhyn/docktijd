import AppKit

/// Gold bezel, champagne dial, serif numerals, tapered dark hands.
struct RetroGoldFace: ClockFace {
    let id = "retroGold"
    let name = "Retro Gold"
    let kind = FaceKind.analogue
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        let c = CGPoint(x: body.midX, y: body.midY)
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x3B2A1C))
        ctx.drawLinearGradient(D.gradient([D.color(0x5A4029), D.color(0x24180F)]),
                               start: CGPoint(x: c.x, y: body.maxY), end: CGPoint(x: c.x, y: body.minY), options: [])
        let r = u * 0.44
        // gold bezel
        D.linearFill(ctx, path: D.circlePath(c, r), from: CGPoint(x: c.x - r, y: c.y + r), to: CGPoint(x: c.x + r, y: c.y - r),
                     colors: [D.color(0xF8E39A), D.color(0xC9972B), D.color(0xFBE9A6), D.color(0x9B6F1C)])
        let dial = r * 0.86
        D.radialFill(ctx, circle: c, radius: dial, colors: [D.color(0xFFF6DC), D.color(0xE9D4A0)],
                     focus: CGPoint(x: c.x - dial * 0.2, y: c.y + dial * 0.25))
        D.strokeCircle(ctx, c, dial, width: u * 0.006, D.color(0x7A5A1A, alpha: 0.8))
        D.ticks(ctx, center: c, count: 60, from: dial * 0.93, to: dial * 0.97, width: u * 0.005,
                color: D.color(0x4A3410, alpha: 0.7), skip: { $0 % 5 == 0 })
        let serif = NSFont(name: "Didot", size: u * 0.085) ?? NSFont.systemFont(ofSize: u * 0.085, weight: .semibold)
        D.numerals(center: c, radius: dial * 0.76, font: serif, color: NSColor(cgColor: D.color(0x3A2A0E))!,
                   labels: ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII"],
                   only: { [12, 3, 6, 9].contains($0) })
        D.ticks(ctx, center: c, count: 12, from: dial * 0.84, to: dial * 0.95, width: u * 0.012,
                color: D.color(0x4A3410), skip: { [0, 3, 6, 9].contains($0) })
        let a = D.angles(for: time)
        let ink = D.color(0x2B1D08)
        D.hand(ctx, center: c, angle: a.hour, length: dial * 0.5, width: u * 0.05, tipWidth: u * 0.012, tail: dial * 0.08,
               color: ink, shadow: (u * 0.012, 0.3))
        D.hand(ctx, center: c, angle: a.minute, length: dial * 0.8, width: u * 0.036, tipWidth: u * 0.008, tail: dial * 0.1,
               color: ink, shadow: (u * 0.012, 0.3))
        D.fillCircle(ctx, c, u * 0.026, D.color(0xC9972B))
        D.fillCircle(ctx, c, u * 0.010, ink)
        ctx.restoreGState()
    }
}
