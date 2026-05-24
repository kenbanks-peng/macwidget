import SwiftUI

public final class DraggableHostingView<Content: View>: NSHostingView<Content> {
    private var dragStartMouseLocation: NSPoint?
    private var dragStartWindowOrigin: NSPoint?

    public override func mouseDown(with event: NSEvent) {
        guard let window else { return }

        dragStartMouseLocation = NSEvent.mouseLocation
        dragStartWindowOrigin = window.frame.origin
    }

    public override func mouseDragged(with event: NSEvent) {
        guard
            let window,
            let dragStartMouseLocation,
            let dragStartWindowOrigin
        else { return }

        let mouseLocation = NSEvent.mouseLocation
        window.setFrameOrigin(NSPoint(
            x: dragStartWindowOrigin.x + mouseLocation.x - dragStartMouseLocation.x,
            y: dragStartWindowOrigin.y + mouseLocation.y - dragStartMouseLocation.y
        ))
    }

    public override func mouseUp(with event: NSEvent) {
        dragStartMouseLocation = nil
        dragStartWindowOrigin = nil
    }
}
