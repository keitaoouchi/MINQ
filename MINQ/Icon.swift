import UIKit

struct Icon {
  static var homeImage: UIImage {
    return UIImage.ionicon(with: .home, textColor: .white, size: Style.Size.tabBarIcon)
  }

  static var searchImage: UIImage {
    return UIImage.ionicon(with: .search, textColor: .white, size: Style.Size.tabBarIcon)
  }

  static var settingsImage: UIImage {
    return UIImage.ionicon(with: .androidSettings, textColor: .white, size: Style.Size.tabBarIcon)
  }

  static var likedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .thumbsUp,
      style: .solid,
      textColor: Asset.Colors.green.color,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var unlikedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .thumbsUp,
      style: .regular,
      textColor: .secondaryLabel,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var stockedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .bookmark,
      style: .solid,
      textColor: Asset.Colors.green.color,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var unstockedImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .bookmark,
      style: .regular,
      textColor: .secondaryLabel,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var safariImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .safari,
      style: .brands,
      textColor: .secondaryLabel,
      size: CGSize(width: 30, height: 30)
    )
  }

  static var commentsImage: UIImage {
    return UIImage.fontAwesomeIcon(
      name: .comments,
      style: .regular,
      textColor: .secondaryLabel,
      size: CGSize(width: 30, height: 30)
    )
  }
}
