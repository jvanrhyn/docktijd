import AppKit

/// Sunset gradient with a frosted pill holding rounded digits.
struct PillFace: ClockFace {
    let id = "pill"
    let name = "Pill"
    let kind = FaceKind.digital
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0xFF6A5A))
        ctx.drawLinearGradient(D.gradient([D.color(0xFF9A6B), D.color(0xF0486F), D.color(0x6B3FD0)], [0, 0.55, 1]),
                               start: CGPoint(x: body.minX, y: body.maxY), end: CGPoint(x: body.maxX, y: body.minY), options: [])
        // frosted pill
        let pill = CGRect(x: body.midX - u * 0.4, y: body.midY - u * 0.17, width: u * 0.8, height: u * 0.34)
        let pp = CGPath(roundedRect: pill, cornerWidth: pill.height / 2, cornerHeight: pill.height / 2, transform: nil)
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -u * 0.02), blur: u * 0.05, color: CGColor(gray: 0, alpha: 0.3))
        ctx.addPath(pp)
        ctx.setFillColor(D.color(0xFFFFFF, alpha: 0.94))
        ctx.fillPath()
        ctx.restoreGState()
        let font = DigitalDrawing.font(u * 0.205, weight: .bold, rounded: true)
        let t = DigitalDrawing.digits(for: time, use24Hour: use24Hour)
        D.text(t.text, at: CGPoint(x: pill.midX, y: pill.midY), font: font, color: NSColor(cgColor: D.color(0x2A1B4D))!)
        if let m = t.meridiem {
            D.text(m, at: CGPoint(x: body.midX, y: pill.minY - u * 0.075),
                   font: DigitalDrawing.font(u * 0.075, weight: .heavy, rounded: true, mono: false),
                   color: NSColor(white: 1, alpha: 0.9), kern: u * 0.012)
        }
        ctx.restoreGState()
    }
}
