import AppKit

enum FaceRenderer {
    /// Renders `face` into a bitmap-backed NSImage of `size` points at `scale` pixels per point.
    static func image(face: any ClockFace, time: ClockTime, size: CGSize,
                      use24Hour: Bool, scale: CGFloat = 2) -> NSImage {
        let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: max(1, Int(size.width * scale)), pixelsHigh: max(1, Int(size.height * scale)),
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
        rep.size = size
        if let gc = NSGraphicsContext(bitmapImageRep: rep) {
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = gc
            face.draw(in: gc.cgContext, rect: CGRect(origin: .zero, size: size), time: time, use24Hour: use24Hour)
            NSGraphicsContext.restoreGraphicsState()
        }
        let image = NSImage(size: size)
        image.addRepresentation(rep)
        return image
    }
}
