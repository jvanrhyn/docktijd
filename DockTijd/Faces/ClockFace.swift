import CoreGraphics

enum FaceKind: Sendable { case analogue, digital }

protocol ClockFace: Sendable {
    var id: String { get }
    var name: String { get }
    var kind: FaceKind { get }
    var showsSeconds: Bool { get }
    /// Draws the whole icon (including the icon-shape background) into `rect`.
    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool)

    /// Faces that tick every second split their drawing so the unchanging part (background, dial,
    /// numerals) is rendered once and cached. Contract: `drawStatic` then `drawDynamic` == `draw`.
    var cachesStaticLayer: Bool { get }
    func drawStatic(in ctx: CGContext, rect: CGRect, use24Hour: Bool)
    func drawDynamic(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool)
}

extension ClockFace {
    var cachesStaticLayer: Bool { false }
    func drawStatic(in ctx: CGContext, rect: CGRect, use24Hour: Bool) {}
    func drawDynamic(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool) {
        draw(in: ctx, rect: rect, time: time, use24Hour: use24Hour)
    }
}
