import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = FaceStore()
    private let view = ClockView(frame: .zero)
    private var engine: ClockEngine!
    private var observers: [(NotificationCenter, NSObjectProtocol)] = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        let tile = NSApp.dockTile
        view.frame = NSRect(origin: .zero, size: tile.size)
        tile.contentView = view
        view.face = FaceRegistry.face(id: store.selectedID)

        engine = ClockEngine { [weak self] time in
            guard let self else { return }
            self.view.time = time
            NSApp.dockTile.display()
        }
        engine.perSecond = view.face.showsSeconds
        engine.start()
        observeSystem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        engine?.stop()
    }

    /// Switches the live face and redraws immediately.
    func select(_ face: any ClockFace) {
        store.selectedID = face.id
        view.face = FaceRegistry.face(id: face.id)
        engine.perSecond = face.showsSeconds
        view.use24Hour = SystemClockFormat.uses24Hour
        engine.reschedule()
    }

    private func observeSystem() {
        let wsCenter = NSWorkspace.shared.notificationCenter
        let center = NotificationCenter.default
        func add(_ c: NotificationCenter, _ name: Notification.Name, _ action: @escaping @MainActor (AppDelegate) -> Void) {
            let token = c.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                MainActor.assumeIsolated { if let self { action(self) } }
            }
            observers.append((c, token))
        }
        add(wsCenter, NSWorkspace.willSleepNotification) { $0.engine.stop() }
        add(wsCenter, NSWorkspace.didWakeNotification) { $0.engine.start() }
        add(center, .NSSystemClockDidChange) { $0.engine.reschedule() }
        add(center, NSLocale.currentLocaleDidChangeNotification) {
            $0.view.use24Hour = SystemClockFormat.uses24Hour
            $0.engine.reschedule()
        }
    }
}
