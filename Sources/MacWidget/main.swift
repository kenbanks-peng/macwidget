import AppKit
import CPUWidget
import DummyWidget
import WidgetKitShared

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let widgetManager = DesktopWidgetManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        widgetManager.add(CPUWidget.make())
        widgetManager.add(DummyWidget.make())
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
