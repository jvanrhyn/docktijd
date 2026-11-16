import AppKit

@MainActor
final class DockMenuBuilder: NSObject {
    private let store: FaceStore
    private let loginItem: any LoginItemControlling
    private let onSelect: (any ClockFace) -> Void
    private var previews: [String: NSImage] = [:]

    static let previewTime = ClockTime(hour: 10, minute: 10, second: 30)
    static let previewSize = CGSize(width: 32, height: 32)

    init(store: FaceStore, loginItem: any LoginItemControlling, onSelect: @escaping (any ClockFace) -> Void) {
        self.store = store
        self.loginItem = loginItem
        self.onSelect = onSelect
    }

    func makeMenu() -> NSMenu {
        let menu = NSMenu()
        let selected = store.selectedID
        for (title, kind) in [("Analogue", FaceKind.analogue), ("Digital", .digital)] {
            menu.addItem(NSMenuItem.sectionHeader(title: title))
            for face in FaceRegistry.all where face.kind == kind {
                let item = NSMenuItem(title: face.name, action: #selector(faceChosen(_:)), keyEquivalent: "")
                item.target = self
                item.representedObject = face.id
                item.state = face.id == selected ? .on : .off
                item.image = preview(for: face)
                menu.addItem(item)
            }
        }
        menu.addItem(.separator())
        let login = NSMenuItem(title: "Open at Login", action: #selector(toggleLogin(_:)), keyEquivalent: "")
        login.target = self
        login.state = loginItem.isEnabled ? .on : .off
        menu.addItem(login)
        return menu
    }

    private func preview(for face: any ClockFace) -> NSImage {
        if let cached = previews[face.id] { return cached }
        let image = FaceRenderer.image(face: face, time: Self.previewTime, size: Self.previewSize, use24Hour: true)
        previews[face.id] = image
        return image
    }

    @objc private func faceChosen(_ sender: NSMenuItem) {
        guard let id = sender.representedObject as? String else { return }
        store.selectedID = id
        onSelect(FaceRegistry.face(id: id))
    }

    @objc private func toggleLogin(_ sender: NSMenuItem) {
        do { try loginItem.setEnabled(!loginItem.isEnabled) } catch { NSSound.beep() }
    }
}
