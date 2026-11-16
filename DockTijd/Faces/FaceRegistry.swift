enum FaceRegistry {
    static let all: [any ClockFace] = [
        ClassicFace(), MinimalDarkFace(), RailwayFace(), AquaFace(), RetroGoldFace(),
    ]

    static func face(id: String) -> any ClockFace {
        all.first { $0.id == id } ?? ClassicFace()
    }

    static func contains(id: String) -> Bool { all.contains { $0.id == id } }
}
