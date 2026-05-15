# SentinelGuard X 🛡️

**SentinelGuard X** is a modern, high-performance, native macOS security platform designed to provide 24/7 protection without the heavy resource usage of traditional antivirus software. 

Built entirely in **Swift 6** with **SwiftUI** and native Apple frameworks, SentinelGuard X operates completely unprivileged, proving that robust security monitoring can be achieved safely without relying on dangerous kernel extensions.

![SentinelGuard X Dashboard](https://github.com/PTharaka/SentinelGuard-X/assets/placeholder_dashboard.png) *(Note: Add screenshots here!)*

---

## 🌟 Key Features

### 🛡️ 24/7 Real-Time Guard
- **File System Monitoring**: Uses macOS `FSEvents` to monitor `~/Downloads`, `~/Desktop`, and `/Applications` in real-time.
- **Instant Scanning**: Automatically hashes and scans new files against a custom database of signatures and behavioral rules the moment they hit your disk.
- **Allowlisting**: Smartly ignores safe macOS system files (like `.DS_Store` and `.localized`) to prevent false positives.

### 🧬 Advanced Threat Detection
- **Signature Engine**: Identifies adware, trojans, crypto-miners, and ransomware using SHA-256 matching.
- **Behavioral Analysis**: Scans scripts and executables for malicious content patterns (e.g., reverse shells, privilege escalation, obfuscation).
- **Smart Quarantine**: Safely isolates detected threats to prevent execution.

### 🔐 System Security Audit
- **App Integrity Checker**: Verifies Apple code cryptographic signatures (`codesign`) for all apps in `/Applications` to detect unauthorized tampering or unsigned software.
- **Posture Analysis**: Live tracking of your Mac's core defenses: **FileVault** encryption, **System Integrity Protection (SIP)**, and **macOS Firewall**.
- **HTML Reporting**: Export a comprehensive, styled HTML security audit report to your desktop with one click.

### 🌐 Network & Hardware Monitoring
- **Live Connection Tracking**: Parses live `lsof` data to monitor open ports and network connections.
- **Suspicious Port Flagging**: Automatically highlights apps connecting to known malicious or non-standard ports.
- **USB Device Monitor**: Uses `DiskArbitration` to detect when a removable USB drive is plugged in, instantly prompting a targeted security scan.

### 🧹 Optimization & Privacy
- **System Cleaner**: Reclaims disk space by identifying system caches, log files, and Application Support clutter.
- **Startup Optimizer**: Analyzes LaunchAgents and LaunchDaemons to detect persistence mechanisms and speed up boot times.
- **Browser Privacy**: Cleans up tracking cookies and browser data across Safari and Chrome.

---

## 🛠️ Technical Architecture

SentinelGuard X is built to respect modern macOS security paradigms:

- **Swift 6 Concurrency**: Fully leverages `async/await`, `Actors`, and `@Observable` for a highly responsive, thread-safe UI.
- **Zero Special Entitlements**: Achieves powerful monitoring using standard unprivileged APIs, avoiding system instability.
- **Native Integration**:
  - `UserNotifications` for critical threat alerts.
  - `MenuBarExtra` for persistent background monitoring and quick actions.
  - `DiskArbitration` for hardware event listening.

---

## 🚀 Getting Started

### Prerequisites
- macOS 14.0 (Sonoma) or later
- Xcode 15+ 

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/PTharaka/SentinelGuard-X.git
   cd SentinelGuard-X
   ```
2. Open `Package.swift` in Xcode.
3. Select the **SentinelGuardX** target and click Run (CMD+R).

### Running via Terminal
```bash
swift build
swift run
```

---

## 📜 Disclaimer
SentinelGuard X is a concept application developed for educational and demonstration purposes regarding macOS security frameworks. Always maintain reliable, verified backups of your data.

## 📄 License
This project is licensed under the MIT License.
