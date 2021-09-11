import UIKit
import IoniconsKit

struct AppInfo {
  static var bundleID: String {
    return Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? "com.keita.oouchi.MINQ"
  }

  static var buildNumber: String {
    return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
  }

  static var versionNumber: String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.1"
  }
}
