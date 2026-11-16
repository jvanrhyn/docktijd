import AppKit

/// Two flip-clock cards with a centre hinge line.
struct FlipFace: ClockFace {
    let id = "flip"
    let name = "Flip"
    let kind = FaceKind.digital
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x2A2A2D))
        ctx.drawLinearGradient(D.gradient([D.color(0x3A3A3F), D.color(0x18181A)]),
                               start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
        let cardW = u * 0.36, cardH = u * 0.52, gap = u * 0.05
        let font = DigitalDrawing.font(u * 0.27, weight: .bold, rounded: true)
        let texts = [DigitalDrawing.hh(time, use24Hour: use24Hour), DigitalDrawing.mm(time)]
        for i in 0..<2 {
            let x = body.midX + (i == 0 ? -gap / 2 - cardW : gap / 2)
            let card = CGRect(x: x, y: body.midY - cardH / 2, width: cardW, height: cardH)
            let path = CGPath(roundedRect: card, cornerWidth: u * 0.04, cornerHeight: u * 0.04, transform: nil)
            ctx.saveGState()
            ctx.setShadow(offset: CGSize(width: 0, height: -u * 0.012), blur: u * 0.025, color: CGColor(gray: 0, alpha: 0.6))
            ctx.addPath(path)
            ctx.setFillColor(D.color(0x0E0E10))
            ctx.fillPath()
            ctx.restoreGState()
            // upper half slightly lighter
            ctx.saveGState()
            ctx.addPath(path); ctx.clip()
            ctx.setFillColor(D.color(0xFFFFFF, alpha: 0.06))
            ctx.fill(CGRect(x: card.minX, y: card.midY, width: cardW, height: cardH / 2))
            ctx.restoreGState()
            D.text(texts[i], at: CGPoint(x: card.midX, y: card.midY), font: font, color: NSColor(white: 0.96, alpha: 1))
            // hinge line
            ctx.setFillColor(CGColor(gray: 0, alpha: 0.9))
            ctx.fill(CGRect(x: card.minX, y: card.midY - u * 0.005, width: cardW, height: u * 0.01))
        }
        if !use24Hour {
            D.text(time.isPM ? "PM" : "AM", at: CGPoint(x: body.midX, y: body.minY + u * 0.1),
                   font: DigitalDrawing.font(u * 0.06, weight: .bold, mono: false), color: NSColor(white: 1, alpha: 0.55), kern: u * 0.01)
        }
        ctx.restoreGState()
    }
}
