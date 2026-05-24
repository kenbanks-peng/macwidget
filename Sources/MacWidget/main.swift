import AppKit
import CPUWidget
import WidgetKitShared

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let widgetManager = DesktopWidgetManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        widgetManager.add(CPUWidget.make())
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
