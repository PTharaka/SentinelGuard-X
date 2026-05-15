import Foundation
import Observation

@Observable
final class PrivacyMonitor {
    var permissions: [PrivacyPermission] = []

    func analyze() {
        permissions = [
            PrivacyPermission(
                name: "Camera", icon: "camera.fill",
                status: .denied, description: "Camera access for video capture",
                appsWithAccess: ["FaceTime", "Photo Booth"]
            ),
            PrivacyPermission(
                name: "Microphone", icon: "mic.fill",
                status: .denied, description: "Microphone access for audio recording",
                appsWithAccess: ["FaceTime", "Voice Memos"]
            ),
            PrivacyPermission(
                name: "Screen Recording", icon: "rectangle.dashed.badge.record",
                status: .notDetermined, description: "Screen capture and recording",
                appsWithAccess: []
            ),
            PrivacyPermission(
                name: "Accessibility", icon: "accessibility",
                status: .notDetermined, description: "Control and automate UI elements",
                appsWithAccess: []
            ),
            PrivacyPermission(
                name: "Full Disk Access", icon: "internaldrive.fill",
                status: .notDetermined, description: "Access to all files on disk",
                appsWithAccess: ["Terminal"]
            ),
            PrivacyPermission(
                name: "Location", icon: "location.fill",
                status: .denied, description: "GPS and location services",
                appsWithAccess: ["Maps", "Weather"]
            ),
            PrivacyPermission(
                name: "Contacts", icon: "person.crop.circle.fill",
                status: .denied, description: "Access to contact information",
                appsWithAccess: ["Mail", "Messages"]
            ),
            PrivacyPermission(
                name: "Clipboard", icon: "doc.on.clipboard.fill",
                status: .granted, description: "Access to clipboard contents",
                appsWithAccess: []
            ),
        ]
    }
}
