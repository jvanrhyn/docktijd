import Testing
@testable import DockTijd

struct FaceRegistryTests {
    func hasTenFaces() {
        let all = FaceRegistry.all
        #expect(all.count == 10)
        #expect(all.filter { $0.kind == .analogue }.count == 5)
        #expect(all.filter { $0.kind == .digital }.count == 5)
        #expect(Set(all.map(\.id)).count == 10)
        #expect(Set(all.map(\.id)) == ["classic", "minimalDark", "railway", "aqua", "retroGold",
                                        "boldMono", "neon", "flip", "lcd", "pill"])
    }

    @Test func unknownIDFallsBackToClassic() {
        #expect(FaceRegistry.face(id: "nope").id == "classic")
    }

    @Test func knownIDResolves() {
        #expect(FaceRegistry.face(id: "classic").id == "classic")
    }
}
