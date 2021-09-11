import UIKit
import Reusable

final class LoadingCell: UICollectionViewListCell, Reusable {
  let loadingStateView = LoadingStateView(style: .medium)

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = Asset.Colors.bg.color
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    guard !contentView.subviews.contains(loadingStateView) else {
      loadingStateView.indicator.startAnimating()
      return
    }

    contentView.minq.attach(loadingStateView, top: 12, leading: 0, trailing: 0, bottom: -12)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
