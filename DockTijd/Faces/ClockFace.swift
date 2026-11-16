import CoreGraphics

enum FaceKind: Sendable { case analogue, digital }

protocol ClockFace: Sendable {
    var id: String { get }
    var name: String { get }
    var kind: FaceKind { get }
    var showsSeconds: Bool { get }
    /// Draws the whole icon (including the icon-shape background) into `rect`.
    func draw(in ctx: CGContext, rect: CGRect, time: ClockTime, use24Hour: Bool)
}
