import Foundation
import Observation

@Observable
final class CleanerCore {
    var categories: [CleanerCategory] = [.caches, .logs, .browser, .trash]
    var isCleaning = false
    var isAnalyzing = false
    var cleaningProgress: Double = 0
    var totalCleanableSize: UInt64 = 0
    var cleanedSize: UInt64 = 0
    var currentCategory: String = ""

    func analyze() {
        isAnalyzing = true
        totalCleanableSize = 0

        Task {
            let home = FileUtils.homeDirectory()

            // Caches
            let cachesSize = FileUtils.directorySize(at: home.appendingPathComponent("Library/Caches"))
            await MainActor.run {
                if let idx = categories.firstIndex(where: { $0.name == "System Caches" }) {
                    categories[idx].size = cachesSize
                    categories[idx].isAnalyzing = false
                }
            }

            // Logs
            let logsSize = FileUtils.directorySize(at: home.appendingPathComponent("Library/Logs"))
            await MainActor.run {
                if let idx = categories.firstIndex(where: { $0.name == "Log Files" }) {
                    categories[idx].size = logsSize
                    categories[idx].isAnalyzing = false
                }
            }

            // Browser data
            var browserSize: UInt64 = 0
            let browserPaths = [
                "Library/Caches/com.apple.Safari",
                "Library/Caches/Google/Chrome",
                "Library/Caches/Firefox",
                "Library/Caches/BraveSoftware",
                "Library/Caches/com.microsoft.edgemac",
            ]
            for path in browserPaths {
                browserSize += FileUtils.directorySize(at: home.appendingPathComponent(path))
            }
            await MainActor.run {
                if let idx = categories.firstIndex(where: { $0.name == "Browser Data" }) {
                    categories[idx].size = browserSize
                    categories[idx].isAnalyzing = false
                }
            }

            // Trash
            let trashSize = FileUtils.directorySize(at: home.appendingPathComponent(".Trash"))
            await MainActor.run {
                if let idx = categories.firstIndex(where: { $0.name == "Trash" }) {
                    categories[idx].size = trashSize
                    categories[idx].isAnalyzing = false
                }
            }

            await MainActor.run {
                self.totalCleanableSize = cachesSize + logsSize + browserSize + trashSize
                self.isAnalyzing = false
            }
        }
    }

    func clean() {
        let selected = categories.filter { $0.isSelected && $0.size > 0 }
        guard !selected.isEmpty else { return }

        isCleaning = true
        cleaningProgress = 0
        cleanedSize = 0

        Task {
            let total = selected.count
            for (index, cat) in selected.enumerated() {
                await MainActor.run {
                    self.currentCategory = cat.name
                    self.cleaningProgress = Double(index) / Double(total)
                }

                // Simulate cleaning delay (real cleaning would delete files)
                try? await Task.sleep(for: .seconds(1))

                await MainActor.run {
                    self.cleanedSize += cat.size
                    if let idx = self.categories.firstIndex(where: { $0.name == cat.name }) {
                        self.categories[idx].size = 0
                    }
                }
            }

            await MainActor.run {
                self.cleaningProgress = 1.0
                self.totalCleanableSize = 0
                self.isCleaning = false
                self.currentCategory = "Complete"
            }
        }
    }

    func toggleCategory(_ name: String) {
        if let idx = categories.firstIndex(where: { $0.name == name }) {
            categories[idx].isSelected.toggle()
        }
    }
}
