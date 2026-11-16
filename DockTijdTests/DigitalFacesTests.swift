import Testing
import AppKit
@testable import DockTijd

struct DigitalFacesTests {
    static let digitalIDs = ["boldMono", "neon", "flip", "lcd", "pill"]

    @Test func twelveHourAtMidnight() {
        let d = DigitalDrawing.digits(for: ClockTime(hour: 0, minute: 5, second: 0), use24Hour: false)
        #expect(d.text == "12:05" && d.meridiem == "AM")
    }

    @Test func twentyFourHourPadsAndHasNoMeridiem() {
        let d = DigitalDrawing.digits(for: ClockTime(hour: 0, minute: 5, second: 0), use24Hour: true)
        #expect(d.text == "00:05" && d.meridiem == nil)
    }

    @Test func twelveHourAfternoonUnpadded() {
        let d = DigitalDrawing.digits(for: ClockTime(hour: 13, minute: 0, second: 0), use24Hour: false)
        #expect(d.text == "1:00" && d.meridiem == "PM")
    }

    @Test func noonIsTwelvePM() {
        let d = DigitalDrawing.digits(for: ClockTime(hour: 12, minute: 0, second: 0), use24Hour: false)
        #expect(d.text == "12:00" && d.meridiem == "PM")
    }

    @Test func allFiveDigitalFacesRegistered() {
        let ids = FaceRegistry.all.filter { $0.kind == .digital }.map(\.id)
        #expect(Set(ids) == Set(Self.digitalIDs))
    }

    @Test(arguments: digitalIDs)
    func secondsChangePixelsOnlyIfFaceShowsSeconds(id: String) {
        let face = FaceRegistry.face(id: id)
        let size = CGSize(width: 128, height: 128)
        let a = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 10, second: 30), size: size, use24Hour: true)
        let b = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 10, second: 45), size: size, use24Hour: true)
        #expect((Pixels.data(of: a) != Pixels.data(of: b)) == face.showsSeconds, "\(id)")
    }

    @Test(arguments: digitalIDs)
    func minuteChangesPixels(id: String) {
        let face = FaceRegistry.face(id: id)
        let size = CGSize(width: 128, height: 128)
        let a = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 10, second: 0), size: size, use24Hour: true)
        let b = FaceRenderer.image(face: face, time: ClockTime(hour: 10, minute: 11, second: 0), size: size, use24Hour: true)
        #expect(Pixels.data(of: a) != Pixels.data(of: b), "\(id)")
    }

    @Test(arguments: digitalIDs)
    func rendersEdgeTimesIn12And24Hour(id: String) {
        let face = FaceRegistry.face(id: id)
        for (h, m) in [(0, 0), (12, 0), (23, 59)] {
            for is24 in [true, false] {
                let img = FaceRenderer.image(face: face, time: ClockTime(hour: h, minute: m, second: 59),
                                             size: CGSize(width: 64, height: 64), use24Hour: is24)
                #expect(Pixels.alphaBounds(of: img).opaqueCount > 0)
            }
        }
    }
}
