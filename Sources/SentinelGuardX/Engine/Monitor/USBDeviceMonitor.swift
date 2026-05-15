import Foundation
import DiskArbitration
import UserNotifications
import Observation

@Observable
final class USBDeviceMonitor {
    var isMonitoring = false
    private var session: DASession?
    
    func startMonitoring() {
        guard !isMonitoring else { return }
        
        guard let session = DASessionCreate(kCFAllocatorDefault) else {
            print("[SentinelGuardX] Failed to create DASession")
            return
        }
        self.session = session
        
        // Register for disk mount events
        let matchDict = [
            kDADiskDescriptionVolumeNetworkKey: false // Exclude network volumes
        ] as CFDictionary
        
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        DARegisterDiskAppearedCallback(session, matchDict, diskAppearedCallback, selfPtr)
        
        // Run on a background queue
        let queue = DispatchQueue(label: "com.sentinelguardx.usbmonitor", qos: .background)
        DASessionSetDispatchQueue(session, queue)
        
        isMonitoring = true
    }
    
    func stopMonitoring() {
        guard let session = session else { return }
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        DAUnregisterCallback(session, diskAppearedCallback, selfPtr)
        DASessionSetDispatchQueue(session, nil)
        self.session = nil
        isMonitoring = false
    }
    
    fileprivate func handleDiskAppeared(disk: DADisk) {
        guard let description = DADiskCopyDescription(disk) as? [String: Any] else { return }
        
        // Check if it's an external or removable device
        let isInternal = description[kDADiskDescriptionDeviceInternalKey as String] as? Bool ?? true
        let isRemovable = description[kDADiskDescriptionMediaRemovableKey as String] as? Bool ?? false
        
        if !isInternal || isRemovable {
            // Get the volume name
            let volumeName = description[kDADiskDescriptionVolumeNameKey as String] as? String ?? "External Drive"
            
            // Only alert if it has a mount path
            if description[kDADiskDescriptionVolumePathKey as String] != nil {
                sendUSBMountNotification(volumeName: volumeName)
            }
        }
    }
    
    private func sendUSBMountNotification(volumeName: String) {
        let content = UNMutableNotificationContent()
        content.title = "🔌 USB Drive Detected"
        content.body = "SentinelGuard X detected '\(volumeName)'. Click to run a security scan."
        content.sound = .default
        content.categoryIdentifier = "USB_MOUNT"
        
        let request = UNNotificationRequest(identifier: "usb-\(UUID())", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}

// C-Callback for DiskArbitration
private func diskAppearedCallback(disk: DADisk, context: UnsafeMutableRawPointer?) {
    guard let context = context else { return }
    let monitor = Unmanaged<USBDeviceMonitor>.fromOpaque(context).takeUnretainedValue()
    monitor.handleDiskAppeared(disk: disk)
}
