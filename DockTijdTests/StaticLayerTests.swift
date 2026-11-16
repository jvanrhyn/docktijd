import Testing
import AppKit
@testable import DockTijd

struct StaticLayerTests {
    static func render(_ size: Int, _ body: (CGContext, CGRect) -> Void) -> Data {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size, bitsPerSample: 8,
                                   samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                                   bytesPerRow: 0, bitsPerPixel: 0)!
        let gc = NSGraphicsContext(bitmapImageRep: rep)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = gc
        body(gc.cgContext, CGRect(x: 0, y: 0, width: size, height: size))
        NSGraphicsContext.restoreGraphicsState()
        return rep.representation(using: .png, properties: [:])!
    }

    @Test func perSecondFacesCacheAStaticLayer() {
        for face in FaceRegistry.all where face.showsSeconds { #expect(face.cachesStaticLayer, "\(face.id)") }
    }

    @Test func staticPlusDynamicEqualsFullDraw() {
        let t = ClockTime(hour: 13, minute: 42, second: 17)
        for face in FaceRegistry.all where face.cachesStaticLayer {
            for is24 in [true, false] {
                let full = Self.render(128) { ctx, r in face.draw(in: ctx, rect: r, time: t, use24Hour: is24) }
                let layered = Self.render(128) { ctx, r in
                    face.drawStatic(in: ctx, rect: r, use24Hour: is24)
                    face.drawDynamic(in: ctx, rect: r, time: t, use24Hour: is24)
                }
                #expect(full == layered, "\(face.id) 24h=\(is24)")
            }
        }
    }

    @Test func cacheReturnsSameImageForSameKeyAndNewOneWhenKeyChanges() {
        let cache = StaticLayerCache()
        let face = FaceRegistry.face(id: "railway")
        let a = cache.image(for: face, size: CGSize(width: 64, height: 64), scale: 2, use24Hour: true)
        let b = cache.image(for: face, size: CGSize(width: 64, height: 64), scale: 2, use24Hour: true)
        let c = cache.image(for: face, size: CGSize(width: 128, height: 128), scale: 2, use24Hour: true)
        #expect(a === b)
        #expect(a !== c)
        #expect(c.width == 256)
    }
}
