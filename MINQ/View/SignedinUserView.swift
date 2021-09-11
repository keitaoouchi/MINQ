import UIKit

final class SignedinUserView: UIView {
  convenience init(user: User) {
    self.init(frame: .zero)
    setup(with: user)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  func setup(with user: User) {
    let userImage = UIImageView()
    userImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
    userImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
    userImage.kf.setImage(with: try? user.profileImageUrl?.asURL())
    userImage.layer.masksToBounds = true
    userImage.layer.cornerRadius = 24
    let nameLabel = UILabel()
    nameLabel.font = Style.Font.base(17, .bold)
    nameLabel.text = user.id
    let stackView = UIStackView(arrangedSubviews: [
      userImage,
      nameLabel
    ])
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.alignment = .center
    minq.centered(with: stackView)
  }
}
