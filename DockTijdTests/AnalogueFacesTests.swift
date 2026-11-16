import Testing
import AppKit
@testable import DockTijd

struct AnalogueFacesTests {
    static let analogueIDs = ["classic", "minimalDark", "railway", "aqua", "retroGold"]
    static func deg(_ r: CGFloat) -> Double { Double(r) * 180 / .pi }

    @Test func anglesAtSixOClock() {
        let a = AnalogueDrawing.angles(for: ClockTime(hour: 6, minute: 0, second: 0))
        #expect(abs(Self.deg(a.hour) - 180) < 0.001)
        #expect(abs(Self.deg(a.minute)) < 0.001)
    }

    @Test func minuteHandAtQuarterPast() {
        #expect(abs(Self.deg(AnalogueDrawing.angles(for: ClockTime(hour: 3, minute: 15, second: 0)).minute) - 90) < 0.001)
    }

    @Test func hourHandHalfwayAtThreeThirty() {
        #expect(abs(Self.deg(AnalogueDrawing.angles(for: ClockTime(hour: 3, minute: 30, second: 0)).hour) - 105) < 0.001)
    }

    @Test func secondHandAdvancesPerSecond() {
        let a = AnalogueDrawing.angles(for: ClockTime(hour: 0, minute: 0, second: 15))
        #expect(abs(Self.deg(a.second) - 90) < 0.001)
    }

    @Test func allFiveAnalogueFacesRegistered() {
        let ids = FaceRegistry.all.filter { $0.kind == .analogue }.map(\.id)
        #expect(Set(ids) == Set(Self.analogueIDs))
    }

    @Test(arguments: analogueIDs)
    func secondsChangePixelsOnlyIfFaceShowsSeconds(id: String) {
        let face = FaceRegistry.face(id: id)
        let size = CGSize(width: 128, height: 128)
        let a = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 10, second: 30), size: size, use24Hour: true)
        let b = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 10, second: 45), size: size, use24Hour: true)
        let differs = Pixels.data(of: a) != Pixels.data(of: b)
        #expect(differs == face.showsSeconds, "\(id)")
    }

    @Test(arguments: analogueIDs)
    func minuteChangesPixels(id: String) {
        let face = FaceRegistry.face(id: id)
        let size = CGSize(width: 128, height: 128)
        let a = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 10, second: 0), size: size, use24Hour: true)
        let b = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 11, second: 0), size: size, use24Hour: true)
        #expect(Pixels.data(of: a) != Pixels.data(of: b), "\(id)")
    }
}
