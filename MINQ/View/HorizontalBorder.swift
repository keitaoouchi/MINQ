import UIKit
import Reusable

final class HorizontalBorder: UICollectionReusableView, Reusable {
  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .separator
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
