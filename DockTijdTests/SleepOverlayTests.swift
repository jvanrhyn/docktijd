import Testing
import AppKit
@testable import DockTijd

struct SleepOverlayTests {
    static func render(progress: Double, side: Int = 128) -> NSImage {
        let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: side, pixelsHigh: side, bitsPerSample: 8,
                                   samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB,
                                   bytesPerRow: 0, bitsPerPixel: 0)!
        let gc = NSGraphicsContext(bitmapImageRep: rep)!
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = gc
        SleepOverlay.draw(in: gc.cgContext, rect: CGRect(x: 0, y: 0, width: side, height: side), progress: progress)
        NSGraphicsContext.restoreGraphicsState()
        let image = NSImage(size: NSSize(width: side, height: side))
        image.addRepresentation(rep)
        return image
    }

    @Test func drawsNothingAtZero() {
        #expect(Pixels.alphaBounds(of: Self.render(progress: 0)).opaqueCount == 0)
    }

    @Test func drawsInsideIconShapeAtOne() {
        let info = Pixels.alphaBounds(of: Self.render(progress: 1))
        #expect(info.opaqueCount > 0)
        let shape = IconShape.path(in: CGRect(x: 0, y: 0, width: info.width, height: info.height)).boundingBox.insetBy(dx: -2, dy: -2)
        #expect(shape.contains(info.rect!))
    }

    @Test func clampsOutOfRangeProgress() {
        #expect(Pixels.alphaBounds(of: Self.render(progress: -3)).opaqueCount == 0)
        #expect(Pixels.alphaBounds(of: Self.render(progress: 9)).opaqueCount == Pixels.alphaBounds(of: Self.render(progress: 1)).opaqueCount)
    }
}
