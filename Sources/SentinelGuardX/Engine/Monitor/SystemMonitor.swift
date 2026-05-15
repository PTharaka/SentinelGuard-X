import Foundation
import Observation
import Darwin

@Observable
final class SystemMonitor {
    var cpuUsage: Double = 0
    var memoryUsage: Double = 0
    var diskUsage: Double = 0
    var totalMemoryGB: Double = 0
    var usedMemoryGB: Double = 0
    var totalDiskGB: Double = 0
    var usedDiskGB: Double = 0
    var processCount: Int = 0
    var isMonitoring = false

    private var timer: Timer?
    private var prevUserTicks: UInt64 = 0
    private var prevSystemTicks: UInt64 = 0
    private var prevIdleTicks: UInt64 = 0
    private var prevNiceTicks: UInt64 = 0
    private var firstRead = true

    func startMonitoring() {
        isMonitoring = true
        updateMetrics()
        timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            self?.updateMetrics()
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        isMonitoring = false
    }

    private func updateMetrics() {
        updateCPU()
        updateMemory()
        updateDisk()
        updateProcessCount()
    }

    private func updateCPU() {
        var cpuInfo = host_cpu_load_info_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<host_cpu_load_info_data_t>.stride / MemoryLayout<integer_t>.stride
        )

        let result = withUnsafeMutablePointer(to: &cpuInfo) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, intPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else { return }

        let user = UInt64(cpuInfo.cpu_ticks.0)
        let system = UInt64(cpuInfo.cpu_ticks.1)
        let idle = UInt64(cpuInfo.cpu_ticks.2)
        let nice = UInt64(cpuInfo.cpu_ticks.3)

        if firstRead {
            prevUserTicks = user; prevSystemTicks = system
            prevIdleTicks = idle; prevNiceTicks = nice
            firstRead = false
            cpuUsage = 0
            return
        }

        let dUser = user - prevUserTicks
        let dSystem = system - prevSystemTicks
        let dIdle = idle - prevIdleTicks
        let dNice = nice - prevNiceTicks
        let dTotal = dUser + dSystem + dIdle + dNice
        let dUsed = dUser + dSystem + dNice

        cpuUsage = dTotal > 0 ? (Double(dUsed) / Double(dTotal)) * 100.0 : 0

        prevUserTicks = user; prevSystemTicks = system
        prevIdleTicks = idle; prevNiceTicks = nice
    }

    private func updateMemory() {
        let total = ProcessInfo.processInfo.physicalMemory
        totalMemoryGB = Double(total) / 1_073_741_824

        var vmStats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64_data_t>.stride / MemoryLayout<integer_t>.stride
        )

        let result = withUnsafeMutablePointer(to: &vmStats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { intPtr in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, intPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else { return }

        let pageSize = UInt64(vm_kernel_page_size)
        let active = UInt64(vmStats.active_count) * pageSize
        let wired = UInt64(vmStats.wire_count) * pageSize
        let compressed = UInt64(vmStats.compressor_page_count) * pageSize
        let used = active + wired + compressed

        usedMemoryGB = Double(used) / 1_073_741_824
        memoryUsage = totalMemoryGB > 0 ? (usedMemoryGB / totalMemoryGB) * 100.0 : 0
    }

    private func updateDisk() {
        do {
            let attrs = try FileManager.default.attributesOfFileSystem(forPath: "/")
            let total = attrs[.systemSize] as? UInt64 ?? 0
            let free = attrs[.systemFreeSize] as? UInt64 ?? 0
            let used = total - free

            totalDiskGB = Double(total) / 1_073_741_824
            usedDiskGB = Double(used) / 1_073_741_824
            diskUsage = total > 0 ? (Double(used) / Double(total)) * 100.0 : 0
        } catch {}
    }

    private func updateProcessCount() {
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var size: Int = 0
        sysctl(&mib, UInt32(mib.count), nil, &size, nil, 0)
        processCount = size / MemoryLayout<kinfo_proc>.stride
    }
}
