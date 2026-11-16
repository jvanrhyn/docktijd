import CoreGraphics

/// The standard macOS app-icon rounded square (824/1024 of the canvas, centred).
enum IconShape {
    static let canvasRatio: CGFloat = 824.0 / 1024.0
    static let cornerRatio: CGFloat = 0.2237

    /// The squircle's bounding rect inside a full tile.
    static func bodyRect(in rect: CGRect) -> CGRect {
        let side = min(rect.width, rect.height) * canvasRatio
        return CGRect(x: rect.midX - side / 2, y: rect.midY - side / 2, width: side, height: side)
    }

    static func path(in rect: CGRect) -> CGPath {
        let body = bodyRect(in: rect)
        let r = body.width * cornerRatio
        return CGPath(roundedRect: body, cornerWidth: r, cornerHeight: r, transform: nil)
    }

    /// Draws a soft drop shadow beneath the body, then clips subsequent drawing to the body.
    /// Caller must wrap in saveGState/restoreGState.
    static func beginBody(_ ctx: CGContext, rect: CGRect, fill: CGColor) {
        let p = path(in: rect)
        let s = rect.width / 1024
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: -10 * s), blur: 24 * s,
                      color: CGColor(gray: 0, alpha: 0.35))
        ctx.addPath(p)
        ctx.setFillColor(fill)
        ctx.fillPath()
        ctx.restoreGState()
        ctx.addPath(p)
        ctx.clip()
    }
}
