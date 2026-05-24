import AppKit
import SwiftUI
import WidgetKitShared

public struct CPUWidget {
    @MainActor
    public static func make() -> DesktopWidget<DesktopCPUWidgetView> {
        let model = CPUHistoryModel()
        model.start()

        return DesktopWidget(
            id: "cpu",
            defaultFrame: NSRect(x: 80, y: 120, width: 320, height: 170),
            content: DesktopCPUWidgetView(model: model)
        )
    }
}

public struct DesktopCPUWidgetView: View {
    @ObservedObject var model: CPUHistoryModel

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("CPU")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.green)

                Spacer()

                Text(latestText)
                    .font(.title2.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.white)
            }

            CPUHistoryGraph(samples: model.samples)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if !model.topProcesses.isEmpty {
                VStack(spacing: 4) {
                    ForEach(model.topProcesses) { process in
                        HStack(spacing: 8) {
                            Text(process.name)
                                .lineLimit(1)
                                .truncationMode(.middle)

                            Spacer(minLength: 8)

                            Text(process.cpuPercent.formatted(.number.precision(.fractionLength(1))) + "%")
                                .monospacedDigit()
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.82))
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(.black.opacity(0.78))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.green.opacity(0.28), lineWidth: 1)
                }
        }
        .overlay(alignment: .bottomTrailing) {
            ResizeHandle()
                .padding(8)
        }
        .padding(1)
    }

    private var latestText: String {
        guard let usage = model.latestUsage else { return "--%" }
        return usage.formatted(.percent.precision(.fractionLength(0)))
    }
}

struct ResizeHandle: View {
    var body: some View {
        Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.green.opacity(0.55))
            .padding(4)
            .contentShape(Rectangle())
            .help("Drag to resize")
    }
}

struct CPUHistoryGraph: View {
    let samples: [Double]

    var body: some View {
        Canvas { context, size in
            let rect = CGRect(origin: .zero, size: size)
            drawGrid(in: rect, context: &context)

            guard samples.count > 1 else { return }

            let points = samples.enumerated().map { index, usage in
                CGPoint(
                    x: CGFloat(index) / CGFloat(samples.count - 1) * size.width,
                    y: (1 - CGFloat(usage)) * size.height
                )
            }

            var line = Path()
            line.move(to: points[0])
            points.dropFirst().forEach { line.addLine(to: $0) }

            var fill = line
            fill.addLine(to: CGPoint(x: size.width, y: size.height))
            fill.addLine(to: CGPoint(x: 0, y: size.height))
            fill.closeSubpath()

            context.fill(fill, with: .linearGradient(
                Gradient(colors: [.green.opacity(0.42), .green.opacity(0.03)]),
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            ))
            context.stroke(line, with: .color(.green), lineWidth: 2)
        }
    }

    private func drawGrid(in rect: CGRect, context: inout GraphicsContext) {
        var grid = Path()
        var bounds = Path()

        bounds.move(to: CGPoint(x: 0, y: 0.5))
        bounds.addLine(to: CGPoint(x: rect.width, y: 0.5))
        bounds.move(to: CGPoint(x: 0, y: rect.height - 0.5))
        bounds.addLine(to: CGPoint(x: rect.width, y: rect.height - 0.5))

        for index in 1..<4 {
            let y = rect.height * CGFloat(index) / 4
            grid.move(to: CGPoint(x: 0, y: y))
            grid.addLine(to: CGPoint(x: rect.width, y: y))
        }

        for index in 1..<6 {
            let x = rect.width * CGFloat(index) / 6
            grid.move(to: CGPoint(x: x, y: 0))
            grid.addLine(to: CGPoint(x: x, y: rect.height))
        }

        context.stroke(grid, with: .color(.green.opacity(0.16)), lineWidth: 0.5)
        context.stroke(bounds, with: .color(.green.opacity(0.48)), lineWidth: 1)
    }
}
