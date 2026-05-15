import Foundation

enum FileUtils {
    static func directorySize(at url: URL) -> UInt64 {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: url,
            includingPropertiesForKeys: [.fileSizeKey, .isRegularFileKey],
            options: [.skipsHiddenFiles],
            errorHandler: nil
        ) else { return 0 }

        var total: UInt64 = 0
        for case let fileURL as URL in enumerator {
            guard let values = try? fileURL.resourceValues(forKeys: [.fileSizeKey, .isRegularFileKey]),
                  values.isRegularFile == true,
                  let size = values.fileSize else { continue }
            total += UInt64(size)
        }
        return total
    }

    static func collectFiles(in directories: [URL], extensions: Set<String>? = nil) -> [URL] {
        let fm = FileManager.default
        var files: [URL] = []

        for dir in directories {
            guard let enumerator = fm.enumerator(
                at: dir,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: [.skipsPackageDescendants],
                errorHandler: nil
            ) else { continue }

            for case let fileURL as URL in enumerator {
                guard let values = try? fileURL.resourceValues(forKeys: [.isRegularFileKey]),
                      values.isRegularFile == true else { continue }
                if let exts = extensions {
                    if exts.contains(fileURL.pathExtension.lowercased()) {
                        files.append(fileURL)
                    }
                } else {
                    files.append(fileURL)
                }
            }
        }
        return files
    }

    static func fileExists(at path: String) -> Bool {
        FileManager.default.fileExists(atPath: path)
    }

    static func homeDirectory() -> URL {
        FileManager.default.homeDirectoryForCurrentUser
    }

    static func appSupportDirectory() -> URL {
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/SentinelGuardX")
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
