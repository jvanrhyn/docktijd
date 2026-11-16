// Generates the sleeping-clock AppIcon set.
// Usage (top-level code needs a main.swift, so copy it):
//   mkdir -p /tmp/tool && cp Tools/MakeSleepIcon.swift /tmp/tool/main.swift \
//   && swiftc -O /tmp/tool/main.swift DockTijd/Faces/IconShape.swift -o /tmp/make-sleep-icon \
//   && /tmp/make-sleep-icon DockTijd/Assets.xcassets/AppIcon.appiconset
import AppKit

func col(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat((hex >> 16) & 0xFF) / 255, green: CGFloat((hex >> 8) & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
let space = CGColorSpaceCreateDeviceRGB()
func grad(_ c: [CGColor], _ l: [CGFloat]? = nil) -> CGGradient { CGGradient(colorsSpace: space, colors: c as CFArray, locations: l)! }

/// Draws the 1024x1024 master into ctx.
func drawIcon(_ ctx: CGContext) {
    let rect = CGRect(x: 0, y: 0, width: 1024, height: 1024)
    let body = IconShape.bodyRect(in: rect)
    let c = CGPoint(x: 512, y: 470)
    ctx.saveGState()
    IconShape.beginBody(ctx, rect: rect, fill: col(0x1B2150))
    // night sky
    ctx.drawLinearGradient(grad([col(0x3A3F95), col(0x161A47), col(0x0C0E2B)], [0, 0.6, 1]),
                           start: CGPoint(x: 512, y: body.maxY), end: CGPoint(x: 512, y: body.minY), options: [])
    // stars
    ctx.setFillColor(col(0xFFFFFF, 0.8))
    for (x, y, r) in [(170, 780, 6), (300, 880, 4), (210, 640, 4), (800, 640, 5), (130, 520, 4), (880, 520, 4), (610, 905, 4), (420, 830, 3)] as [(CGFloat, CGFloat, CGFloat)] {
        ctx.fillEllipse(in: CGRect(x: x - r, y: y - r, width: 2 * r, height: 2 * r))
    }
    // crescent moon (top left)
    ctx.saveGState()
    let moon = CGMutablePath()
    moon.addEllipse(in: CGRect(x: 175, y: 735, width: 130, height: 130))
    ctx.addPath(moon); ctx.clip()
    ctx.setFillColor(col(0xFFE9A8)); ctx.fill(CGRect(x: 160, y: 720, width: 170, height: 170))
    ctx.setBlendMode(.clear)
    ctx.fillEllipse(in: CGRect(x: 215, y: 755, width: 120, height: 120))
    ctx.restoreGState()

    // clock body
    let r: CGFloat = 270
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -14), blur: 36, color: col(0x000000, 0.5))
    ctx.setFillColor(col(0xF6EFE0))
    ctx.fillEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r)); ctx.clip()
    ctx.drawRadialGradient(grad([col(0xFFFBF0), col(0xE6DAC0)]), startCenter: CGPoint(x: c.x - 40, y: c.y + 60), startRadius: 0,
                           endCenter: c, endRadius: r, options: [.drawsAfterEndLocation])
    ctx.restoreGState()
    ctx.setStrokeColor(col(0xB9A47A)); ctx.setLineWidth(14)
    ctx.strokeEllipse(in: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))
    // hour ticks
    ctx.setStrokeColor(col(0x6A5A3A, 0.55)); ctx.setLineWidth(10); ctx.setLineCap(.round)
    for i in 0..<12 {
        let a = CGFloat(i) / 12 * 2 * .pi
        ctx.move(to: CGPoint(x: c.x + sin(a) * (r - 38), y: c.y + cos(a) * (r - 38)))
        ctx.addLine(to: CGPoint(x: c.x + sin(a) * (r - 18), y: c.y + cos(a) * (r - 18)))
    }
    ctx.strokePath()
    // closed eyes: downward arcs with lashes
    ctx.setStrokeColor(col(0x2B2418)); ctx.setLineWidth(18); ctx.setLineCap(.round)
    for ex in [c.x - 95, c.x + 95] {
        ctx.addArc(center: CGPoint(x: ex, y: c.y + 30), radius: 50, startAngle: .pi * 1.1, endAngle: .pi * 1.9, clockwise: false)
        ctx.strokePath()
    }
    // blush
    ctx.setFillColor(col(0xFF8FA3, 0.45))
    for ex in [c.x - 150, c.x + 150] { ctx.fillEllipse(in: CGRect(x: ex - 38, y: c.y - 50, width: 76, height: 44)) }
    // sleepy mouth
    ctx.setFillColor(col(0x7A4A3A))
    ctx.fillEllipse(in: CGRect(x: c.x - 20, y: c.y - 105, width: 40, height: 50))
    // tiny hands resting at 10:10 above the mouth are omitted: the eyes are the face.

    // nightcap draped over the top of the clock
    let capBase = CGPoint(x: c.x, y: c.y + r - 10)
    let cap = CGMutablePath()
    cap.move(to: CGPoint(x: capBase.x - 215, y: capBase.y - 55))
    cap.addQuadCurve(to: CGPoint(x: capBase.x + 40, y: capBase.y + 190), control: CGPoint(x: capBase.x - 150, y: capBase.y + 190))
    cap.addQuadCurve(to: CGPoint(x: capBase.x + 300, y: capBase.y - 90), control: CGPoint(x: capBase.x + 250, y: capBase.y + 140))
    cap.addQuadCurve(to: CGPoint(x: capBase.x + 215, y: capBase.y - 55), control: CGPoint(x: capBase.x + 260, y: capBase.y - 80))
    cap.addQuadCurve(to: CGPoint(x: capBase.x - 215, y: capBase.y - 55), control: CGPoint(x: capBase.x, y: capBase.y + 30))
    cap.closeSubpath()
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 18, color: col(0x000000, 0.4))
    ctx.addPath(cap); ctx.setFillColor(col(0xD9344C)); ctx.fillPath()
    ctx.restoreGState()
    ctx.saveGState(); ctx.addPath(cap); ctx.clip()
    ctx.drawLinearGradient(grad([col(0xFF7A8C, 0.55), col(0xD9344C, 0)]), start: CGPoint(x: capBase.x, y: capBase.y + 190),
                           end: CGPoint(x: capBase.x, y: capBase.y - 40), options: [])
    ctx.restoreGState()
    // cap brim
    let brim = CGPath(roundedRect: CGRect(x: capBase.x - 232, y: capBase.y - 95, width: 464, height: 62), cornerWidth: 31, cornerHeight: 31, transform: nil)
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 12, color: col(0x000000, 0.35))
    ctx.addPath(brim); ctx.setFillColor(col(0xFFF8EC)); ctx.fillPath()
    ctx.restoreGState()
    // pom-pom
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -6), blur: 12, color: col(0x000000, 0.35))
    ctx.setFillColor(col(0xFFF8EC))
    ctx.fillEllipse(in: CGRect(x: capBase.x + 262, y: capBase.y - 135, width: 84, height: 84))
    ctx.restoreGState()

    // Z z z
    for (s, size, x, y) in [("z", 70.0, 790.0, 290.0), ("Z", 100.0, 850.0, 380.0), ("Z", 135.0, 862.0, 500.0)] as [(String, CGFloat, CGFloat, CGFloat)] {
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 24, color: col(0x7F8CFF))
        let str = NSAttributedString(string: s, attributes: [
            .font: NSFont.systemFont(ofSize: size, weight: .heavy), .foregroundColor: NSColor.white])
        let sz = str.size()
        str.draw(at: CGPoint(x: x - sz.width / 2, y: y - sz.height / 2))
        ctx.restoreGState()
    }
    ctx.restoreGState()
}

func png(pixels: Int) -> Data {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8,
                               samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                               bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = NSSize(width: 1024, height: 1024) // draw in master coordinates
    let gc = NSGraphicsContext(bitmapImageRep: rep)!
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = gc
    drawIcon(gc.cgContext)
    NSGraphicsContext.restoreGraphicsState()
    rep.size = NSSize(width: pixels, height: pixels)
    return rep.representation(using: .png, properties: [:])!
}

let outDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "AppIcon.appiconset"
try FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)
var images: [[String: String]] = []
for (pt, scale) in [(16, 1), (16, 2), (32, 1), (32, 2), (128, 1), (128, 2), (256, 1), (256, 2), (512, 1), (512, 2)] {
    let px = pt * scale
    let name = "icon_\(pt)x\(pt)@\(scale)x.png"
    try png(pixels: px).write(to: URL(fileURLWithPath: outDir + "/" + name))
    images.append(["idiom": "mac", "size": "\(pt)x\(pt)", "scale": "\(scale)x", "filename": name])
}
let contents: [String: Any] = ["images": images, "info": ["version": 1, "author": "xcode"]]
try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
    .write(to: URL(fileURLWithPath: outDir + "/Contents.json"))
print("wrote \(images.count) icons to \(outDir)")
