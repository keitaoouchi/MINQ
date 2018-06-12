import UIKit
import Reusable
import FluxxKit

final class AuthRequiredView: UIView, NibLoadable {

  @IBAction private func onTapSignin(sender: UIButton) {
    Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
  }
}

extension AuthRequiredView {
  static func fill(in view: UIView?) {
    guard let view = view else { return }

    let authView = AuthRequiredView.loadFromNib()
    view.minq.fill(with: authView)
  }

}
