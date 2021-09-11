import UIKit
import Reusable
import FluxxKit

final class NonSignedinView: UIView {
  private var onSignin: (() -> Void)?

  convenience init(onSignin: @escaping (() -> Void)) {
    self.init(frame: .zero)
    self.onSignin = onSignin
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  private func setup() {
    let mainLabel = UILabel(frame: .zero)
    mainLabel.text = L10n.nonSignedInMainTitle
    mainLabel.font = Style.Font.base(17, .bold)
    let subLabel = UILabel(frame: .zero)
    subLabel.text = L10n.nonSignedInSubTitle
    subLabel.numberOfLines = 0
    subLabel.font = Style.Font.base(15, .regular)
    let button = UIButton(frame: .zero)
    button.setTitle(L10n.login, for: .normal)
    button.setTitleColor(Asset.Colors.blue.color, for: .normal)
    button.titleLabel?.font = Style.Font.base(15, .bold)
    let stackView = UIStackView(arrangedSubviews: [
      mainLabel,
      subLabel,
      button
    ])
    stackView.axis = .vertical
    stackView.spacing = 4
    stackView.alignment = .center
    minq.centered(with: stackView)

    button.addTarget(self, action: #selector(onTapSigninButton), for: .touchUpInside)
  }

  @objc private func onTapSigninButton() {
    onSignin?()
  }
}
