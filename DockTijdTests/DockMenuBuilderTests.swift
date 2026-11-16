import Testing
import AppKit
@testable import DockTijd

final class FakeLoginItem: LoginItemControlling, @unchecked Sendable {
    var isEnabled: Bool
    var shouldThrow = false
    var calls: [Bool] = []
    struct Failure: Error {}
    init(enabled: Bool = false) { isEnabled = enabled }
    func setEnabled(_ on: Bool) throws {
        calls.append(on)
        if shouldThrow { throw Failure() }
        isEnabled = on
    }
}

@MainActor
struct DockMenuBuilderTests {
    static func makeStore() -> FaceStore {
        let name = "menu-\(UUID().uuidString)"
        let d = UserDefaults(suiteName: name)!
        d.removePersistentDomain(forName: name)
        return FaceStore(defaults: d)
    }

    final class Selection { var chosen: [String] = [] }

    static func make(login: FakeLoginItem = FakeLoginItem(), store: FaceStore = makeStore(),
                     selection: Selection = Selection()) -> (DockMenuBuilder, NSMenu, FaceStore, Selection) {
        let b = DockMenuBuilder(store: store, loginItem: login) { selection.chosen.append($0.id) }
        return (b, b.makeMenu(), store, selection)
    }

    @Test func structureIsHeadersFacesSeparatorLogin() {
        let (_, menu, _, _) = Self.make()
        let titles = menu.items.map { $0.isSeparatorItem ? "-" : $0.title }
        #expect(titles.count == 14)
        #expect(titles[0] == "Analogue" && menu.items[0].isSectionHeader)
        #expect(titles[6] == "Digital" && menu.items[6].isSectionHeader)
        #expect(titles[12] == "-")
        #expect(titles[13] == "Open at Login")
        #expect(Array(titles[1...5]) == FaceRegistry.all.filter { $0.kind == .analogue }.map(\.name))
        #expect(Array(titles[7...11]) == FaceRegistry.all.filter { $0.kind == .digital }.map(\.name))
    }

    @Test func exactlyOneFaceIsChecked() {
        let (_, menu, _, _) = Self.make()
        let checked = menu.items.filter { $0.state == .on && $0.title != "Open at Login" }
        #expect(checked.count == 1 && checked[0].title == "Classic")
    }

    @Test func everyFaceItemHasAPreviewImage() {
        let (_, menu, _, _) = Self.make()
        for item in menu.items[1...5] + menu.items[7...11] { #expect(item.image != nil, "\(item.title)") }
    }

    @Test func choosingAFaceCallsOnSelectAndPersists() {
        let (builder, menu, store, sel) = Self.make(); defer { withExtendedLifetime(builder) {} }
        let idx = menu.items.firstIndex { $0.title == "Neon" }!
        menu.performActionForItem(at: idx)
        #expect(sel.chosen == ["neon"])
        #expect(store.selectedID == "neon")
    }

    @Test func loginToggleFlipsCurrentState() {
        let login = FakeLoginItem(enabled: false)
        let (b1, menu, _, _) = Self.make(login: login); defer { withExtendedLifetime(b1) {} }
        #expect(menu.items.last!.state == .off)
        menu.performActionForItem(at: menu.items.count - 1)
        #expect(login.calls == [true])
        let (b2, menu2, _, _) = Self.make(login: login); defer { withExtendedLifetime(b2) {} }
        #expect(menu2.items.last!.state == .on)
        menu2.performActionForItem(at: menu2.items.count - 1)
        #expect(login.calls == [true, false])
    }

    @Test func loginFailureLeavesMenuUsable() {
        let login = FakeLoginItem(enabled: false)
        login.shouldThrow = true
        let (b3, menu, _, _) = Self.make(login: login); defer { withExtendedLifetime(b3) {} }
        menu.performActionForItem(at: menu.items.count - 1)
        let (_, menu2, _, _) = Self.make(login: login)
        #expect(menu2.items.count == 14)
        #expect(menu2.items.last!.state == .off)
    }
}
