import Darwin
import Foundation

struct ProcessCPUUsage: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let cpuPercent: Double
}

final class CPUUsageSampler {
    private var previousLoad: [processor_cpu_load_info]?
    private var previousCount: mach_msg_type_number_t = 0

    func sampleUsage() -> Double? {
        var cpuInfo: processor_info_array_t?
        var cpuInfoCount: mach_msg_type_number_t = 0
        var processorCount: natural_t = 0

        let result = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &processorCount,
            &cpuInfo,
            &cpuInfoCount
        )

        guard result == KERN_SUCCESS, let cpuInfo else {
            return nil
        }

        let pointer = UnsafeBufferPointer(start: cpuInfo, count: Int(cpuInfoCount))
        let loads = stride(from: 0, to: Int(cpuInfoCount), by: Int(CPU_STATE_MAX)).map { offset in
            processor_cpu_load_info(
                cpu_ticks: (
                    UInt32(pointer[offset + Int(CPU_STATE_USER)]),
                    UInt32(pointer[offset + Int(CPU_STATE_SYSTEM)]),
                    UInt32(pointer[offset + Int(CPU_STATE_IDLE)]),
                    UInt32(pointer[offset + Int(CPU_STATE_NICE)])
                )
            )
        }

        defer {
            let byteCount = vm_size_t(cpuInfoCount) * vm_size_t(MemoryLayout<integer_t>.stride)
            vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: cpuInfo)), byteCount)
        }

        guard let previousLoad else {
            self.previousLoad = loads
            self.previousCount = cpuInfoCount
            return nil
        }

        guard previousCount == cpuInfoCount, previousLoad.count == loads.count else {
            self.previousLoad = loads
            self.previousCount = cpuInfoCount
            return nil
        }

        var totalTicks: UInt64 = 0
        var idleTicks: UInt64 = 0

        for index in loads.indices {
            let current = loads[index].cpu_ticks
            let previous = previousLoad[index].cpu_ticks
            let user = UInt64(current.0 &- previous.0)
            let system = UInt64(current.1 &- previous.1)
            let idle = UInt64(current.2 &- previous.2)
            let nice = UInt64(current.3 &- previous.3)

            totalTicks += user + system + idle + nice
            idleTicks += idle
        }

        self.previousLoad = loads
        self.previousCount = cpuInfoCount

        guard totalTicks > 0 else { return nil }
        return min(max(1 - (Double(idleTicks) / Double(totalTicks)), 0), 1)
    }

    func sampleTopProcesses(limit: Int = 3) -> [ProcessCPUUsage] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/ps")
        process.arguments = ["-arcxo", "comm=,pcpu="]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return []
        }

        guard process.terminationStatus == 0 else { return [] }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return [] }

        return output
            .split(separator: "\n")
            .compactMap { line -> ProcessCPUUsage? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard let separator = trimmed.lastIndex(of: " ") else { return nil }

                let name = trimmed[..<separator].trimmingCharacters(in: .whitespaces)
                let cpuText = trimmed[trimmed.index(after: separator)...]
                guard !name.isEmpty, let cpuPercent = Double(cpuText) else { return nil }

                return ProcessCPUUsage(name: String(name), cpuPercent: cpuPercent)
            }
            .prefix(limit + 1)
            .dropFirst()
            .map { $0 }
    }
}
