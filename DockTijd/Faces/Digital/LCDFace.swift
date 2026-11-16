import AppKit

/// Retro seven-segment LCD with ghost segments and a seconds read-out.
struct LCDFace: ClockFace {
    let id = "lcd"
    let name = "LCD"
    let kind = FaceKind.digital
    let showsSeconds = true

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let u = body.width
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x2B2D2A))
        ctx.drawLinearGradient(D.gradient([D.color(0x3E403C), D.color(0x1E1F1D)]),
                               start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
        // LCD well
        let well = body.insetBy(dx: u * 0.07, dy: u * 0.2)
        let wp = CGPath(roundedRect: well, cornerWidth: u * 0.06, cornerHeight: u * 0.06, transform: nil)
        D.linearFill(ctx, path: wp, from: CGPoint(x: well.midX, y: well.maxY), to: CGPoint(x: well.midX, y: well.minY),
                     colors: [D.color(0xC7D8A8), D.color(0xA9BE86)])
        ctx.setStrokeColor(D.color(0x000000, alpha: 0.5))
        ctx.setLineWidth(u * 0.008)
        ctx.addPath(wp); ctx.strokePath()

        ctx.saveGState()
        ctx.addPath(wp); ctx.clip()
        // slight italic slant, like real LCDs
        ctx.concatenate(CGAffineTransform(a: 1, b: 0, c: -0.1, d: 1, tx: well.midY * 0.1, ty: 0))
        let ink = D.color(0x1F2A16), ghost = D.color(0x1F2A16, alpha: 0.08)
        let cw = u * 0.15, ch = u * 0.30, t = u * 0.04, sp = u * 0.035
        let colonW = u * 0.05
        let totalW = 4 * cw + 3 * sp + colonW
        var x = well.midX - totalW / 2
        let y = well.midY - ch / 2 + u * 0.03
        let hour = DigitalDrawing.hh(time, use24Hour: use24Hour)
        let padded = hour.count == 1 ? " " + hour : hour
        let chars = Array(padded + DigitalDrawing.mm(time))
        for (i, c) in chars.enumerated() {
            if i == 2 {
                for dy in [ch * 0.3, ch * 0.7] {
                    D.fillCircle(ctx, CGPoint(x: x + colonW / 2 - sp / 2 + sp / 2, y: y + dy), t * 0.5, ink)
                }
                x += colonW + sp * 0.0
            }
            DigitalDrawing.segmentDigit(ctx, cell: CGRect(x: x, y: y, width: cw, height: ch), ch: c,
                                        thickness: t, onColor: ink, offColor: ghost)
            x += cw + sp
        }
        // seconds, small, bottom right of the well
        let sw = u * 0.06, sh = u * 0.12, st = u * 0.016
        let secs = Array(DigitalDrawing.ss(time))
        var sx = well.maxX - u * 0.04 - 2 * sw - u * 0.02
        for c in secs {
            DigitalDrawing.segmentDigit(ctx, cell: CGRect(x: sx, y: well.minY + u * 0.035, width: sw, height: sh), ch: c,
                                        thickness: st, onColor: ink, offColor: ghost)
            sx += sw + u * 0.02
        }
        ctx.restoreGState()
        if !use24Hour {
            D.text(time.isPM ? "PM" : "AM", at: CGPoint(x: well.minX + u * 0.1, y: well.minY + u * 0.07),
                   font: DigitalDrawing.font(u * 0.06, weight: .heavy, mono: false), color: NSColor(cgColor: ink)!)
        }
        ctx.restoreGState()
    }
}
