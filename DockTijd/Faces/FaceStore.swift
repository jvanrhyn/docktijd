import Foundation

final class FaceStore: @unchecked Sendable {
    static let key = "selectedFaceID"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    var selectedID: String {
        get {
            let stored = defaults.string(forKey: Self.key) ?? ""
            return FaceRegistry.contains(id: stored) ? stored : "classic"
        }
        set {
            guard FaceRegistry.contains(id: newValue) else { return }
            defaults.set(newValue, forKey: Self.key)
        }
    }
}
