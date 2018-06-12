import UIKit
import Reusable
import FluxxKit

final class NonSignedinView: UIView, NibOwnerLoadable {

  var onSignin: (() -> Void)?

  @IBOutlet private weak var signinButton: UIButton!

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.loadNibContent()
    self.configure()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.loadNibContent()
    self.configure()
  }

  private func configure() {
    signinButton.addTarget(self, action: #selector(onTapSigninButton), for: .touchUpInside)
  }

  @objc private func onTapSigninButton() {
    self.onSignin?()
  }
}
