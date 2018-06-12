import UIKit
import Reusable

final class FailedStateView: UIView, NibLoadable {
  @IBOutlet private weak var reloadButton: UIButton!
  var onTapReloadButton: ((UIButton) -> Void)? {
    didSet {
      reloadButton.isHidden = (onTapReloadButton == nil)
    }
  }

  @IBAction private func onTapReload(sender: UIButton) {
    self.onTapReloadButton?(sender)
  }

  static func fill(in view: UIView?) {
    guard let view = view else { return }

    let failedView = FailedStateView.loadFromNib()
    view.minq.fill(with: failedView)
  }
}
