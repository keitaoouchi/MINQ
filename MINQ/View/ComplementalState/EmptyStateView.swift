import UIKit
import Reusable

final class EmptyStateView: UIView, NibLoadable, ComplementalStateView {
  @IBOutlet private var messageLabel: UILabel!
  @IBOutlet private weak var reloadButton: UIButton!
  var onTapReloader: OnTapReloader? {
    didSet {
      reloadButton.isHidden = (onTapReloader == nil)
    }
  }

  @IBAction private func onTapReload(sender: UIButton) {
    onTapReloader?(sender)
  }
}
