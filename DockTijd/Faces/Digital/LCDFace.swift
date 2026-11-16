import AppKit

/// Retro seven-segment LCD with ghost segments and a seconds read-out.
struct LCDFace: ClockFace {
    let id = "lcd"
    let name = "LCD"
    let kind = FaceKind.digital
    let showsSeconds = true
    var cachesStaticLayer: Bool { true }

    private struct Layout {
        let u: CGFloat
        let well: CGRect
        let cw: CGFloat, ch: CGFloat, t: CGFloat, sp: CGFloat, colonW: CGFloat
        let sw: CGFloat, sh: CGFloat, st: CGFloat
        let mainX: CGFloat, mainY: CGFloat
        let secX: CGFloat, secY: CGFloat

        init(rect: CGRect) {
            let body = IconShape.bodyRect(in: rect)
            u = body.width
            well = body.insetBy(dx: u * 0.07, dy: u * 0.2)
            cw = u * 0.15; ch = u * 0.30; t = u * 0.04; sp = u * 0.035; colonW = u * 0.05
            let totalW = 4 * cw + 3 * sp + colonW
            mainX = well.midX - totalW / 2
            mainY = well.midY - ch / 2 + u * 0.03
            sw = u * 0.06; sh = u * 0.12; st = u * 0.016
            secX = well.maxX - u * 0.04 - 2 * sw - u * 0.02
            secY = well.minY + u * 0.035
        }

        /// x of the main digit cell `i` (0...3); the colon sits between cells 1 and 2.
        func cellX(_ i: Int) -> CGFloat { mainX + CGFloat(i) * (cw + sp) + (i >= 2 ? colonW : 0) }
        func cell(_ i: Int) -> CGRect { CGRect(x: cellX(i), y: mainY, width: cw, height: ch) }
        func secCell(_ i: Int) -> CGRect { CGRect(x: secX + CGFloat(i) * (sw + u * 0.02), y: secY, width: sw, height: sh) }
        var slant: CGAffineTransform { CGAffineTransform(a: 1, b: 0, c: -0.1, d: 1, tx: well.midY * 0.1, ty: 0) }
    }

    private static let ink = AnalogueDrawing.color(0x1F2A16)
    private static let ghost = AnalogueDrawing.color(0x1F2A16, alpha: 0.08)

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        drawStatic(in: ctx, rect: rect, use24Hour: use24Hour)
        drawDynamic(in: ctx, rect: rect, time: time, use24Hour: use24Hour)
    }

    /// Case, LCD well and the faint unlit "88:88" segments.
    func drawStatic(in ctx: CGContext, rect: CGRect, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let body = IconShape.bodyRect(in: rect)
        let L = Layout(rect: rect)
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: D.color(0x2B2D2A))
        ctx.drawLinearGradient(D.gradient([D.color(0x3E403C), D.color(0x1E1F1D)]),
                               start: CGPoint(x: body.midX, y: body.maxY), end: CGPoint(x: body.midX, y: body.minY), options: [])
        let wp = CGPath(roundedRect: L.well, cornerWidth: L.u * 0.06, cornerHeight: L.u * 0.06, transform: nil)
        D.linearFill(ctx, path: wp, from: CGPoint(x: L.well.midX, y: L.well.maxY), to: CGPoint(x: L.well.midX, y: L.well.minY),
                     colors: [D.color(0xC7D8A8), D.color(0xA9BE86)])
        ctx.setStrokeColor(D.color(0x000000, alpha: 0.5))
        ctx.setLineWidth(L.u * 0.008)
        ctx.addPath(wp); ctx.strokePath()
        ctx.saveGState()
        ctx.addPath(wp); ctx.clip()
        ctx.concatenate(L.slant)
        for i in 0..<4 {
            DigitalDrawing.segmentDigit(ctx, cell: L.cell(i), ch: "8", thickness: L.t, onColor: Self.ghost, offColor: nil)
        }
        for i in 0..<2 {
            DigitalDrawing.segmentDigit(ctx, cell: L.secCell(i), ch: "8", thickness: L.st, onColor: Self.ghost, offColor: nil)
        }
        ctx.restoreGState()
        ctx.restoreGState()
    }

    /// Lit segments, colon, seconds and AM/PM.
    func drawDynamic(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        typealias D = AnalogueDrawing
        let L = Layout(rect: rect)
        ctx.saveGState()
        ctx.addPath(CGPath(roundedRect: L.well, cornerWidth: L.u * 0.06, cornerHeight: L.u * 0.06, transform: nil))
        ctx.clip()
        ctx.saveGState()
        ctx.concatenate(L.slant)
        let hour = DigitalDrawing.hh(time, use24Hour: use24Hour)
        let chars = Array((hour.count == 1 ? " " + hour : hour) + DigitalDrawing.mm(time))
        for (i, c) in chars.enumerated() {
            DigitalDrawing.segmentDigit(ctx, cell: L.cell(i), ch: c, thickness: L.t, onColor: Self.ink, offColor: nil)
        }
        let colonX = L.cellX(1) + L.cw + L.sp * 0.5 + L.colonW * 0.5
        for dy in [L.ch * 0.3, L.ch * 0.7] { D.fillCircle(ctx, CGPoint(x: colonX, y: L.mainY + dy), L.t * 0.5, Self.ink) }
        for (i, c) in DigitalDrawing.ss(time).enumerated() {
            DigitalDrawing.segmentDigit(ctx, cell: L.secCell(i), ch: c, thickness: L.st, onColor: Self.ink, offColor: nil)
        }
        ctx.restoreGState()
        if !use24Hour {
            D.text(time.isPM ? "PM" : "AM", at: CGPoint(x: L.well.minX + L.u * 0.1, y: L.well.minY + L.u * 0.07),
                   font: DigitalDrawing.font(L.u * 0.06, weight: .heavy, mono: false), color: NSColor(cgColor: Self.ink)!)
        }
        ctx.restoreGState()
    }
}
