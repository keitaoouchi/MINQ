import UIKit
import Reusable

final class LoadingStateView: UIView, NibLoadable {
  @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
}

extension LoadingStateView {
  static func fill(in view: UIView?) {
    guard let view = view else { return }

    let loadingView = LoadingStateView.loadFromNib()
    view.minq.fill(with: loadingView)
  }

}
