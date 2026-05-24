import AppKit
import SwiftUI

public struct DesktopWidget<Content: View> {
    public let id: String
    public let defaultFrame: NSRect
    public let content: Content

    public init(id: String, defaultFrame: NSRect, content: Content) {
        self.id = id
        self.defaultFrame = defaultFrame
        self.content = content
    }
}

public final class DesktopWidgetManager {
    private var windows: [NSPanel] = []

    public init() {}

    public func add<Content: View>(_ widget: DesktopWidget<Content>) {
        let window = DesktopWidgetPanel(
            contentRect: widget.defaultFrame,
            frameAutosaveKey: "DesktopWidgetPanelFrame.\(widget.id)",
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        window.contentView = DraggableHostingView(rootView: widget.content)
        window.makeKeyAndOrderFront(nil)
        windows.append(window)
    }
}
