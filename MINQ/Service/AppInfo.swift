import UIKit
import IoniconsKit

struct AppInfo {}

extension AppInfo {
  static let tabBarIconSize = CGSize(width: 32, height: 32)
}

// MARK: - API
extension AppInfo {
  static let perPage = 20
}

// MARK: - Image
extension AppInfo {

  static var homeImage: UIImage {
    return UIImage.ionicon(with: .home, textColor: .white, size: tabBarIconSize)
  }

  static var searchImage: UIImage {
    return UIImage.ionicon(with: .search, textColor: .white, size: tabBarIconSize)
  }

  static var settingsImage: UIImage {
    return UIImage.ionicon(with: .androidSettings, textColor: .white, size: tabBarIconSize)
  }

  static var likedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .thumbsUp,
      textColor: Asset.Colors.green.color,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var unlikedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .thumbsOUp,
      textColor: Asset.Colors.gray.color,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var stockedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .bookmark,
      textColor: Asset.Colors.green.color,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var unstockedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .bookmarkO,
      textColor: Asset.Colors.gray.color,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var safariImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .safari,
      textColor: Asset.Colors.gray.color,
      size: CGSize(width: 30, height: 30)
    )
  }
}

// MARK: - Size
extension AppInfo {
  static let currentTagsMinumumHeight: CGFloat = 132.0
  static let followingTagsMinimumHeight: CGFloat = 264.0

  static let menuItemFontSize: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 20
    } else {
      return 15
    }
  }()

  static let menuViewHeight: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 56
    } else {
      return 40
    }
  }()

  static let commentMarkSize: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 24
    } else {
      return 18
    }
  }()

  static let stockMarkSize: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 24
    } else {
      return 18
    }
  }()

  static let tagSize: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 18
    } else {
      return 14
    }
  }()
}

// MARK: - MISC
extension AppInfo {

  static var outdatedLimit: TimeInterval = 60.0 * 60.0 * 24.0 * 7.0

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
