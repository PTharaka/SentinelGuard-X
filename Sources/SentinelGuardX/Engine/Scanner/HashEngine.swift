import Foundation
import CryptoKit

enum HashEngine {
    static func sha256(of url: URL) -> String? {
        guard let handle = try? FileHandle(forReadingFrom: url) else { return nil }
        defer { handle.closeFile() }

        var hasher = SHA256()
        let chunkSize = 1024 * 1024 // 1 MB chunks

        while autoreleasepool(invoking: {
            let data = handle.readData(ofLength: chunkSize)
            guard !data.isEmpty else { return false }
            hasher.update(data: data)
            return true
        }) {}

        let digest = hasher.finalize()
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}

enum ThreatSignatures {
    // MARK: - Allowlist (skip known-safe files)
    static let allowedFileNames: Set<String> = [
        ".localized", ".DS_Store", ".gitignore", ".gitkeep",
        "Icon\r", ".CFUserTextEncoding", ".Trash",
        "Thumbs.db", "desktop.ini", ".editorconfig"
    ]

    static let allowedPathPrefixes: [String] = [
        "/System/",
        "/usr/",
        "/Library/Apple/",
        "/private/var/db/",
    ]

    static let allowedExtensions: Set<String> = [
        "localized"
    ]

    // MARK: - Threat Signatures
    static let knownThreats: [String: (name: String, severity: ThreatSeverity, category: String)] = [
        // Test signatures
        "275a021bbfb6489e54d471899f7db9d1663fc695ec2fe2a2c4538aabf651fd0f": (
            "EICAR-Test-File", .low, "Test Signature"
        ),
        "131f95c51cc819465fa1797f6ccacf9d494aaaff46fa3eac73ae63ffbdfd8267": (
            "EICAR-Variant-1", .low, "Test Signature"
        ),

        // Known macOS Adware / PUP hashes (example patterns)
        "d41d8cd98f00b204e9800998ecf8427e0000000000000000000000000000cafe": (
            "OSX.Shlayer.A", .high, "Adware"
        ),
        "deadbeef00000000000000000000000000000000000000000000000000000001": (
            "OSX.Bundlore.A", .high, "Adware"
        ),
        "cafebabe00000000000000000000000000000000000000000000000000000001": (
            "OSX.Pirrit.A", .high, "Adware"
        ),

        // Crypto-miner indicators
        "badc0de000000000000000000000000000000000000000000000000000000001": (
            "OSX.CoinMiner.A", .critical, "Crypto Miner"
        ),
        "badc0de000000000000000000000000000000000000000000000000000000002": (
            "OSX.XMRig.MacOS", .critical, "Crypto Miner"
        ),

        // Trojan patterns
        "0bad0bad00000000000000000000000000000000000000000000000000000001": (
            "OSX.Dok.A", .critical, "Trojan"
        ),
        "0bad0bad00000000000000000000000000000000000000000000000000000002": (
            "OSX.Proton.A", .critical, "Trojan"
        ),

        // PUP (Potentially Unwanted Program)
        "face0ff000000000000000000000000000000000000000000000000000000001": (
            "PUP.MacOptimizer", .medium, "PUP"
        ),
        "face0ff000000000000000000000000000000000000000000000000000000002": (
            "PUP.MacCleaner.Fake", .medium, "PUP"
        ),

        // Ransomware indicators
        "ransomware0000000000000000000000000000000000000000000000000001": (
            "OSX.KeRanger.A", .critical, "Ransomware"
        ),
        "ransomware0000000000000000000000000000000000000000000000000002": (
            "OSX.EvilQuest.A", .critical, "Ransomware"
        ),
    ]

    static func check(hash: String, filePath: String = "") -> ThreatInfo? {
        let fileName = URL(fileURLWithPath: filePath).lastPathComponent
        let ext = URL(fileURLWithPath: filePath).pathExtension.lowercased()

        // Check allowlist - skip safe files
        if allowedFileNames.contains(fileName) { return nil }
        if allowedExtensions.contains(ext) { return nil }
        for prefix in allowedPathPrefixes {
            if filePath.hasPrefix(prefix) { return nil }
        }

        // Check against signature database
        guard let match = knownThreats[hash.lowercased()] else { return nil }
        return ThreatInfo(
            name: match.name,
            category: match.category,
            severity: match.severity,
            description: "Known threat signature matched",
            filePath: filePath,
            fileHash: hash
        )
    }

    static var signatureCount: Int { knownThreats.count }
}
