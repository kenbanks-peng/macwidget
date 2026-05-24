import AppKit
import SwiftUI
import WidgetKitShared

public struct DummyWidget {
    public static func make() -> DesktopWidget<DummyWidgetView> {
        DesktopWidget(
            id: "dummy",
            defaultFrame: NSRect(x: 430, y: 120, width: 220, height: 120),
            content: DummyWidgetView()
        )
    }
}

public struct DummyWidgetView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dummy")
                .font(.headline.weight(.semibold))
                .foregroundStyle(.cyan)

            Text("Widget manager online")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.82))

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.black.opacity(0.78))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.cyan.opacity(0.32), lineWidth: 1)
                }
        }
        .padding(1)
    }
}
