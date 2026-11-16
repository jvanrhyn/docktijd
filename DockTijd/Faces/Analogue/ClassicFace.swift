import CoreGraphics

struct ClassicFace: ClockFace {
    let id = "classic"
    let name = "Classic"
    let kind = FaceKind.analogue
    let showsSeconds = false

    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        ctx.saveGState()
        IconShape.beginBody(ctx, rect: rect, fill: CGColor(gray: 0.97, alpha: 1))
        let body = IconShape.bodyRect(in: rect)
        let c = CGPoint(x: body.midX, y: body.midY)
        ctx.setStrokeColor(CGColor(gray: 0.1, alpha: 1))
        ctx.setLineCap(.round)
        let h = CGFloat((time.hour % 12)) / 12 + CGFloat(time.minute) / 720
        let m = CGFloat(time.minute) / 60
        for (frac, len, w) in [(h, 0.25, 0.04), (m, 0.38, 0.03)] as [(CGFloat, CGFloat, CGFloat)] {
            let a = frac * 2 * .pi
            ctx.setLineWidth(body.width * w)
            ctx.move(to: c)
            ctx.addLine(to: CGPoint(x: c.x + sin(a) * body.width * len, y: c.y + cos(a) * body.width * len))
            ctx.strokePath()
        }
        ctx.restoreGState()
    }
}
