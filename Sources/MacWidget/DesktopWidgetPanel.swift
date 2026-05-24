import AppKit

final class DesktopWidgetPanel: NSPanel {
    private let frameAutosaveKey = "DesktopWidgetPanelFrame"

    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: backingStoreType,
            defer: flag
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        ignoresMouseEvents = false
        isMovableByWindowBackground = true
        minSize = NSSize(width: 260, height: 150)
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]

        // This puts the panel behind normal windows but above the wallpaper,
        // approximating a desktop widget without WidgetKit/Xcode/signing.
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopIconWindow)) + 1)

        setFrameUsingName(frameAutosaveKey)
        setFrameAutosaveName(frameAutosaveKey)
    }

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
