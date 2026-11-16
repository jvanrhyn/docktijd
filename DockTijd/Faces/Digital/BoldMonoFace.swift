import AppKit

/// Hours over minutes in huge white mono type on black.
struct BoldMonoFace: ClockFace {
    let id = "boldMono"
    let name = "Bold Mono"
    let kind = FaceKind.digital
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x000000))
        ctx.drawLinearGradient(D.gradient([D.color(0x1C1C1E), D.color(0x000000)]),
                               start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
        let big = DigitalDrawing.font(u * 0.46, weight: .heavy)
        let white = NSColor.white
        D.text(DigitalDrawing.hh(time, use24Hour: use24Hour), at: CGPoint(x: body.midX, y: body.midY + u * 0.19), font: big, color: white)
        D.text(DigitalDrawing.mm(time), at: CGPoint(x: body.midX, y: body.midY - u * 0.19), font: big,
               color: NSColor(white: 1, alpha: 0.55))
        if !use24Hour {
            D.text(time.isPM ? "PM" : "AM", at: CGPoint(x: body.maxX - u * 0.12, y: body.minY + u * 0.08),
                   font: DigitalDrawing.font(u * 0.065, weight: .bold, mono: false), color: NSColor(white: 1, alpha: 0.5), kern: u * 0.004)
        }
        ctx.restoreGState()
    }
}
