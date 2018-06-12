import UIKit
import Reusable

final class EmptyStateView: UIView, NibLoadable {
  @IBOutlet private var messageLabel: UILabel!
  @IBOutlet private weak var reloadButton: UIButton!
  var onTapReloadButton: ((UIButton) -> Void)? {
    didSet {
      reloadButton.isHidden = (onTapReloadButton == nil)
    }
  }

  @IBAction private func onTapReload(sender: UIButton) {
    self.onTapReloadButton?(sender)
  }

  static func fill(in view: UIView?, message: String? = nil, animation: Bool = false) {
    guard let view = view else { return }

    let emptyView = EmptyStateView.loadFromNib()
    view.minq.fill(with: emptyView)

    if let message = message {
      emptyView.messageLabel.text = message
    }

    if animation {
      emptyView.alpha = 0.0
      UIView.animate(withDuration: 0.3) {
        emptyView.alpha = 1.0
      }
    }
  }
}
