import UIKit
import Reusable

final class ReloadableFooterView: UICollectionReusableView, NibReusable {
  @IBOutlet private var labels: [UILabel]!

  func setErrorMessage(_ str: String, color: UIColor) {
    labels.first?.text = str
    labels.first?.textColor = color
  }
}
