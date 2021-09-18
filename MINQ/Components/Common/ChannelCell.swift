import UIKit
import Reusable

final class ChannelCell: UICollectionViewListCell, Reusable {
  override init(frame: CGRect) {
    super.init(frame: frame)

    let config = UIBackgroundConfiguration.listGroupedCell()
    backgroundConfiguration = config
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func apply(tag: FollowingTag) {
    var content = defaultContentConfiguration()
    content.text = tag.id
    contentConfiguration = content
  }
}

final class EmptyCell: UICollectionViewListCell, Reusable {
  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = Asset.Colors.bg.color
    contentView.minq.fill(with: EmptyStateView.loadFromNib())
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class AuthRequiredCell: UICollectionViewListCell, Reusable {
  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = Asset.Colors.bg.color
    contentView.minq.fill(with: AuthRequiredView.loadFromNib())
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

final class FailedCell: UICollectionViewListCell, Reusable {
  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.backgroundColor = Asset.Colors.bg.color
    contentView.minq.fill(with: FailedStateView.loadFromNib())
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
