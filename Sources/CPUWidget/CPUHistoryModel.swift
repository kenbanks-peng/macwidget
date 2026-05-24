import Foundation

@MainActor
final class CPUHistoryModel: ObservableObject {
    @Published private(set) var samples: [Double] = []
    @Published private(set) var topProcesses: [ProcessCPUUsage] = []

    private let sampler = CPUUsageSampler()
    private var timer: Timer?
    private let maxSamples = 90
    private let topProcessSampleInterval = 5
    private var sampleCount = 0

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
        sampleCount += 1
        samples.append(usage)
        if sampleCount == 1 || sampleCount.isMultiple(of: topProcessSampleInterval) {
            topProcesses = sampler.sampleTopProcesses()
        }
        if samples.count > maxSamples {
            samples.removeFirst(samples.count - maxSamples)
        }
    }
}
