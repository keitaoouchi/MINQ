import UIKit
import Reusable
import FluxxKit

final class AuthRequiredView: UIView, NibLoadable, ComplementalStateView {

  @IBAction private func onTapSignin(sender: UIButton) {
    Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
  }
}
