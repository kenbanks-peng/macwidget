import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSPanel!
    private var model: CPUHistoryModel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        model = CPUHistoryModel()
        let contentView = DesktopCPUWidgetView(model: model)

        window = DesktopWidgetPanel(
            contentRect: NSRect(x: 80, y: 120, width: 320, height: 170),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.contentView = DraggableHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)

        model.start()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()

