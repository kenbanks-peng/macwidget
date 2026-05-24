import Foundation

@MainActor
final class CPUHistoryModel: ObservableObject {
    @Published private(set) var samples: [Double] = []

    private let sampler = CPUUsageSampler()
    private var timer: Timer?
    private let maxSamples = 90

    var latestUsage: Double? {
        samples.last
    }

    func start() {
        _ = sampler.sampleUsage()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.sample()
            }
        }
    }

    private func sample() {
        guard let usage = sampler.sampleUsage() else { return }
        samples.append(usage)
        if samples.count > maxSamples {
            samples.removeFirst(samples.count - maxSamples)
        }
    }
}

