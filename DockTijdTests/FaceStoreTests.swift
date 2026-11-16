import Testing
import Foundation
@testable import DockTijd

struct FaceStoreTests {
    static func suite() -> UserDefaults {
        let name = "test-\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return d
    }

    @Test func defaultsToClassic() {
        #expect(FaceStore(defaults: Self.suite()).selectedID == "classic")
    }

    @Test func persistsAcrossInstances() {
        let d = Self.suite()
        FaceStore(defaults: d).selectedID = "classic"
        #expect(FaceStore(defaults: d).selectedID == "classic")
        #expect(d.string(forKey: "selectedFaceID") == "classic")
    }

    @Test func garbageStoredIDReadsAsClassic() {
        let d = Self.suite()
        d.set("garbage", forKey: "selectedFaceID")
        #expect(FaceStore(defaults: d).selectedID == "classic")
    }

    @Test func settingUnknownIDIsIgnored() {
        let d = Self.suite()
        let s = FaceStore(defaults: d)
        s.selectedID = "bogus"
        #expect(s.selectedID == "classic")
    }
}
