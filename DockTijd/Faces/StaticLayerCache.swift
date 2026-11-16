import AppKit

/// Holds the most recent pre-rendered static layer (one entry: only the visible face matters).
final class StaticLayerCache: @unchecked Sendable {
    private struct Key: Equatable { let id: String; let size: CGSize; let scale: CGFloat; let use24Hour: Bool }
    private let lock = NSLock()
    private var key: Key?
    private var cached: CGImage?

    func image(for face: any ClockFace, size: CGSize, scale: CGFloat, use24Hour: Bool) -> CGImage {
        let k = Key(id: face.id, size: size, scale: scale, use24Hour: use24Hour)
        lock.lock(); defer { lock.unlock() }
        if k == key, let cached { return cached }
        let w = max(1, Int(size.width * scale)), h = max(1, Int(size.height * scale))
        let ctx = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0,
                            space: CGColorSpace(name: CGColorSpace.sRGB)!,
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue)!
        ctx.scaleBy(x: scale, y: scale)
        let gc = NSGraphicsContext(cgContext: ctx, flipped: false)
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = gc
        face.drawStatic(in: ctx, rect: CGRect(origin: .zero, size: size), use24Hour: use24Hour)
        NSGraphicsContext.restoreGraphicsState()
        let image = ctx.makeImage()!
        key = k; cached = image
        return image
    }
}
