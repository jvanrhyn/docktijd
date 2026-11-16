import AppKit

/// Glowing cyan/magenta digits on a deep indigo gradient.
struct NeonFace: ClockFace {
    let id = "neon"
    let name = "Neon"
    let kind = FaceKind.digital
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x120A2E))
        ctx.drawLinearGradient(D.gradient([D.color(0x2B1055), D.color(0x0A0620)]),
                               start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
        // neon frame
        let frame = body.insetBy(dx: u * 0.055, dy: u * 0.055)
        let fp = CGPath(roundedRect: frame, cornerWidth: u * 0.16, cornerHeight: u * 0.16, transform: nil)
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: u * 0.05, color: D.color(0xFF2BD6))
        ctx.setStrokeColor(D.color(0xFF5AE0))
        ctx.setLineWidth(u * 0.012)
        ctx.addPath(fp)
        ctx.strokePath()
        ctx.restoreGState()
        // glowing digits
        let font = DigitalDrawing.font(u * 0.255, weight: .bold, rounded: true)
        let t = DigitalDrawing.digits(for: time, use24Hour: use24Hour).text
        for (blur, color) in [(u * 0.07, 0x00E5FF), (u * 0.02, 0x00E5FF)] as [(CGFloat, UInt32)] {
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: blur, color: D.color(color))
            D.text(t, at: CGPoint(x: body.midX, y: body.midY), font: font, color: NSColor(cgColor: D.color(0xBFFBFF))!)
            ctx.restoreGState()
        }
        if !use24Hour {
            ctx.saveGState()
            ctx.setShadow(offset: .zero, blur: u * 0.03, color: D.color(0xFF2BD6))
            D.text(time.isPM ? "PM" : "AM", at: CGPoint(x: body.midX, y: body.midY - u * 0.2),
                   font: DigitalDrawing.font(u * 0.07, weight: .semibold, mono: false), color: NSColor(cgColor: D.color(0xFFB3F1))!, kern: u * 0.01)
            ctx.restoreGState()
        }
        ctx.restoreGState()
    }
}
