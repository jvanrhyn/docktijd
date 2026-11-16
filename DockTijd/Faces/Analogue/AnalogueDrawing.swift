import AppKit

/// Shared geometry and drawing helpers for analogue faces. Angles are radians clockwise from 12 o'clock.
enum AnalogueDrawing {
    static let rgb = CGColorSpaceCreateDeviceRGB()

    static func angles(for t: ClockTime) -> (hour: CGFloat, minute: CGFloat, second: CGFloat) {
        let twoPi = 2 * CGFloat.pi
        let hour = (CGFloat(t.hour % 12) + CGFloat(t.minute) / 60) / 12 * twoPi
        let minute = CGFloat(t.minute) / 60 * twoPi
        let second = CGFloat(t.second) / 60 * twoPi
        return (hour, minute, second)
    }

    static func point(from c: CGPoint, angle: CGFloat, radius: CGFloat) -> CGPoint {
        CGPoint(x: c.x + sin(angle) * radius, y: c.y + cos(angle) * radius)
    }

    static func color(_ hex: UInt32, alpha: CGFloat = 1) -> CGColor {
        CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255,
                blue: CGFloat(hex & 0xFF) / 255, alpha: alpha)
    }

    static func gradient(_ colors: [CGColor], _ locations: [CGFloat]? = nil) -> CGGradient {
        CGGradient(colorsSpace: rgb, colors: colors as CFArray, locations: locations)!
    }

    static func circlePath(_ c: CGPoint, _ r: CGFloat) -> CGPath {
        CGPath(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r), transform: nil)
    }

    static func fillCircle(_ ctx: CGContext, _ c: CGPoint, _ r: CGFloat, _ color: CGColor) {
        ctx.setFillColor(color)
        ctx.addPath(circlePath(c, r))
        ctx.fillPath()
    }

    static func strokeCircle(_ ctx: CGContext, _ c: CGPoint, _ r: CGFloat, width: CGFloat, _ color: CGColor) {
        ctx.setStrokeColor(color)
        ctx.setLineWidth(width)
        ctx.addPath(circlePath(c, r))
        ctx.strokePath()
    }

    static func radialFill(_ ctx: CGContext, circle c: CGPoint, radius r: CGFloat, colors: [CGColor],
                           focus: CGPoint? = nil) {
        ctx.saveGState()
        ctx.addPath(circlePath(c, r))
        ctx.clip()
        let f = focus ?? c
        ctx.drawRadialGradient(gradient(colors), startCenter: f, startRadius: 0, endCenter: c, endRadius: r,
                               options: [.drawsAfterEndLocation])
        ctx.restoreGState()
    }

    static func linearFill(_ ctx: CGContext, path: CGPath, from: CGPoint, to: CGPoint, colors: [CGColor]) {
        ctx.saveGState()
        ctx.addPath(path)
        ctx.clip()
        ctx.drawLinearGradient(gradient(colors), start: from, end: to, options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        ctx.restoreGState()
    }

    /// Radial ticks between radii; `every` selects which of the `count` positions get this style.
    static func ticks(_ ctx: CGContext, center c: CGPoint, count: Int, from r0: CGFloat, to r1: CGFloat,
                      width: CGFloat, color: CGColor, skip: (Int) -> Bool = { _ in false }) {
        ctx.saveGState()
        ctx.setStrokeColor(color)
        ctx.setLineWidth(width)
        ctx.setLineCap(.round)
        for i in 0..<count where !skip(i) {
            let a = CGFloat(i) / CGFloat(count) * 2 * .pi
            ctx.move(to: point(from: c, angle: a, radius: r0))
            ctx.addLine(to: point(from: c, angle: a, radius: r1))
        }
        ctx.strokePath()
        ctx.restoreGState()
    }

    /// A hand drawn as a rounded bar (or tapered if tipWidth < width), pivoting at `c`.
    static func hand(_ ctx: CGContext, center c: CGPoint, angle: CGFloat, length: CGFloat, width: CGFloat,
                     tipWidth: CGFloat? = nil, tail: CGFloat = 0, color: CGColor,
                     shadow: (blur: CGFloat, alpha: CGFloat)? = nil) {
        ctx.saveGState()
        ctx.translateBy(x: c.x, y: c.y)
        ctx.rotate(by: -angle)
        if let s = shadow {
            ctx.setShadow(offset: CGSize(width: 0, height: -width * 0.25), blur: s.blur, color: CGColor(gray: 0, alpha: s.alpha))
        }
        let tip = tipWidth ?? width
        let path = CGMutablePath()
        if tip == width {
            path.addPath(CGPath(roundedRect: CGRect(x: -width / 2, y: -tail, width: width, height: length + tail),
                                cornerWidth: width / 2, cornerHeight: width / 2, transform: nil))
        } else {
            path.move(to: CGPoint(x: -width / 2, y: -tail))
            path.addLine(to: CGPoint(x: width / 2, y: -tail))
            path.addLine(to: CGPoint(x: tip / 2, y: length))
            path.addLine(to: CGPoint(x: -tip / 2, y: length))
            path.closeSubpath()
        }
        ctx.addPath(path)
        ctx.setFillColor(color)
        ctx.fillPath()
        ctx.restoreGState()
    }

    /// Draws centred text using the current NSGraphicsContext (always set by ClockView and FaceRenderer).
    static func text(_ s: String, at p: CGPoint, font: NSFont, color: NSColor, kern: CGFloat = 0) {
        let str = NSAttributedString(string: s, attributes: [.font: font, .foregroundColor: color, .kern: kern])
        let size = str.size()
        str.draw(at: CGPoint(x: p.x - size.width / 2, y: p.y - size.height / 2))
    }

    /// Numerals 1...12 on a circle.
    static func numerals(center c: CGPoint, radius: CGFloat, font: NSFont, color: NSColor,
                         labels: [String] = (1...12).map(String.init), only: (Int) -> Bool = { _ in true }) {
        for (i, label) in labels.enumerated() where only(i + 1) {
            let a = CGFloat(i + 1) / 12 * 2 * .pi
            text(label, at: point(from: c, angle: a, radius: radius), font: font, color: color)
        }
    }
}
