import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    let store = FaceStore()
    private let view = ClockView(frame: .zero)
    private var engine: ClockEngine!
    private var sleepTimer: Timer?
    private lazy var menuBuilder = DockMenuBuilder(store: store, loginItem: SMAppServiceLoginItem()) { [weak self] face in
        self?.apply(face)
    }
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

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        engine?.stop()
        guard view.sleepProgress == 0 else { return .terminateLater }
        // Brief fall-asleep fade (~0.35 s), then really quit.
        let start = ProcessInfo.processInfo.systemUptime
        let duration = 0.35
        let timer = Timer(timeInterval: 1.0 / 30, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return }
                let p = min(1, (ProcessInfo.processInfo.systemUptime - start) / duration)
                self.view.sleepProgress = p
                NSApp.dockTile.display()
                if p >= 1 {
                    self.sleepTimer?.invalidate()
                    self.sleepTimer = nil
                    NSApp.reply(toApplicationShouldTerminate: true)
                }
            }
        }
        sleepTimer = timer
        RunLoop.main.add(timer, forMode: .common)
        return .terminateLater
    }

    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        menuBuilder.makeMenu()
    }

    /// Switches the live face and redraws immediately (selection is already persisted by the menu).
    func apply(_ face: any ClockFace) {
        view.face = face
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
