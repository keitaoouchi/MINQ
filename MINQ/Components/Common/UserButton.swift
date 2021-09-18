import UIKit

final class UserButton: UIControl {
  let titleLabel: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryLabel
    label.font = Style.Font.userButton
    return label
  }()

  let imageView: UIImageView = {
    let view = UIImageView()
    view.backgroundColor = .clear
    view.layer.masksToBounds = true
    view.layer.cornerRadius = 12.0
    view.widthAnchor.constraint(equalToConstant: 24).isActive = true
    view.heightAnchor.constraint(equalToConstant: 24).isActive = true
    return view
  }()

  override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: 32)
  }

  init() {
    super.init(frame: .zero)

    addSubview(titleLabel)
    addSubview(imageView)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
      imageView.trailingAnchor.constraint(equalTo: titleLabel.leadingAnchor, constant: -12.0),
      titleLabel.topAnchor.constraint(equalTo: topAnchor),
      titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
      titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(user: User) {
    imageView.kf.setImage(with: try? user.profileImageUrl?.asURL())
    titleLabel.text = user.id
  }
}
