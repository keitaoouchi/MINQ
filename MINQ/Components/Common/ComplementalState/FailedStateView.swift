import UIKit
import Reusable

final class FailedStateView: UIView, NibLoadable, ComplementalStateView {
  @IBOutlet private weak var reloadButton: UIButton!
  var onTapReloader: ((UIControl) -> Void)? {
    didSet {
      reloadButton.isHidden = (onTapReloader == nil)
    }
  }

  @IBAction private func onTapReload(sender: UIButton) {
    onTapReloader?(sender)
  }
}
