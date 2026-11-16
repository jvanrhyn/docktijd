import Testing
@testable import DockTijd

@MainActor
struct SmokeTests {
    @Test func appDelegateExists() {
        _ = AppDelegate()
    }
}
