import ServiceManagement

protocol LoginItemControlling: Sendable {
    var isEnabled: Bool { get }
    func setEnabled(_ on: Bool) throws
}

struct SMAppServiceLoginItem: LoginItemControlling {
    var isEnabled: Bool { SMAppService.mainApp.status == .enabled }

    func setEnabled(_ on: Bool) throws {
        if on { try SMAppService.mainApp.register() } else { try SMAppService.mainApp.unregister() }
    }
}
