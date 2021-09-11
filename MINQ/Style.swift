import UIKit

struct Style {
  struct Height {}
  struct Size {}
  struct Font {}
  struct FontAwesome {}
  struct Margin {}
}

extension Style.Size {
  static let tabBarIcon = CGSize(width: 32, height: 32)
}

extension Style.Height {
  static let menuView: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 56
    } else {
      return 40
    }
  }()

  static let commentMark: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 24
    } else {
      return 18
    }
  }()

  static let stockMark: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 24
    } else {
      return 18
    }
  }()

  static let tagMark: CGFloat = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return 18
    } else {
      return 14
    }
  }()
}

// MARK: - Font
extension Style.Font {
  static let itemCollectionTitle: UIFont = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .systemFont(ofSize: 28, weight: .bold)
    } else {
      return .systemFont(ofSize: 20, weight: .bold)
    }
  }()

  static let channelCollectionHeader: UIFont = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .systemFont(ofSize: 20)
    } else {
      return .systemFont(ofSize: 15)
    }
  }()

  static let channelCollectionTitle: UIFont = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .systemFont(ofSize: 24)
    } else {
      return .systemFont(ofSize: 17)
    }
  }()

  static let tag: UIFont = {
    .systemFont(ofSize: Style.Height.tagMark)
  }()

  static let userButton: UIFont = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .systemFont(ofSize: 20, weight: .semibold)
    } else {
      return .systemFont(ofSize: 15, weight: .semibold)
    }
  }()

  static func base(_ size: CGFloat, _ weight: UIFont.Weight) -> UIFont {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return .systemFont(ofSize: size + 3, weight: weight)
    } else {
      return .systemFont(ofSize: size, weight: weight)
    }
  }
}

extension Style.FontAwesome {
  static let commentMark = UIFont.fontAwesome(ofSize: Style.Height.commentMark, style: .regular)
  static let stockMark = UIFont.fontAwesome(ofSize: Style.Height.stockMark, style: .regular)
  static let tagMark = UIFont.fontAwesome(ofSize: Style.Height.tagMark, style: .solid)
}

extension Style.Margin {
  static let itemCollection: UIEdgeInsets = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return UIEdgeInsets(top: 24, left: 48, bottom: -24, right: -48)
    } else {
      return UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
    }
  }()

  static let itemDetail: UIEdgeInsets = {
    if UIDevice.current.userInterfaceIdiom == .pad {
      return UIEdgeInsets(top: 24, left: 48, bottom: -24, right: -48)
    } else {
      return UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16)
    }
  }()
}
