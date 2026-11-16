import Testing
import AppKit
@testable import DockTijd

enum Pixels {
    /// RGBA bytes of an image rendered at its point size x scale 1.
    static func alphaBounds(of image: NSImage) -> (opaqueCount: Int, rect: CGRect?, width: Int, height: Int) {
        guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return (0, nil, 0, 0) }
        var count = 0
        var minX = Int.max, minY = Int.max, maxX = -1, maxY = -1
        for y in 0..<rep.pixelsHigh {
            for x in 0..<rep.pixelsWide {
                if let c = rep.colorAt(x: x, y: y), c.alphaComponent > 0.02 {
                    count += 1
                    minX = min(minX, x); maxX = max(maxX, x)
                    minY = min(minY, y); maxY = max(maxY, y)
                }
            }
        }
        let r: CGRect? = count > 0 ? CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1) : nil
        return (count, r, rep.pixelsWide, rep.pixelsHigh)
    }

    static func data(of image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation, let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }
}

struct FaceRendererTests {
    static let t = ClockTime(hour: 10, minute: 10, second: 30)

    @Test(arguments: [32.0, 128.0])
    func rendersAtRequestedSizeWithinIconShape(side: Double) {
        for face in FaceRegistry.all {
            let img = FaceRenderer.image(face: face, time: Self.t, size: CGSize(width: side, height: side), use24Hour: true)
            #expect(img.size == CGSize(width: side, height: side))
            let info = Pixels.alphaBounds(of: img)
            #expect(info.opaqueCount > 0, "\(face.id) drew nothing")
            let shape = IconShape.path(in: CGRect(x: 0, y: 0, width: info.width, height: info.height))
            let margin = Double(info.width) * 0.05 // drop shadow may extend slightly past the body
            let bounds = shape.boundingBox.insetBy(dx: -margin, dy: -margin)
            if let r = info.rect { #expect(bounds.contains(r), "\(face.id) draws outside the icon shape at \(side)") }
        }
    }
}
