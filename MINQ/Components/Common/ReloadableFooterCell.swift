import UIKit
import Reusable

final class ReloadableFooterCell: UICollectionViewListCell, Reusable {
  let reloadableFooterView = ReloadableFooterView.loadFromNib()

  override init(frame: CGRect) {
    super.init(frame: frame)

    reloadableFooterView.isUserInteractionEnabled = false
    contentView.minq.attach(reloadableFooterView, top: 8, leading: 0, trailing: 0, bottom: -8)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
