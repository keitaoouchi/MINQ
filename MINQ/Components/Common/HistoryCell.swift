import UIKit
import Reusable

final class HistoryCell: UITableViewCell, Reusable {
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.font = Style.Font.base(20, .bold)
    return label
  }()

  private let userButton = UserButton()

  private let separator: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = .separator
    view.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    return view
  }()

  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    let stackView = UIStackView(arrangedSubviews: [
      titleLabel,
      userButton
    ])
    stackView.axis = .vertical
    stackView.alignment = .leading
    stackView.spacing = 4
    let margin = Style.Margin.itemCollection
    contentView.minq.attach(stackView, top: margin.top, leading: margin.left, trailing: margin.right, bottom: margin.bottom)
    backgroundColor = Asset.Colors.bg.color
    contentView.addSubview(separator)
    NSLayoutConstraint.activate([
      separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: separatorInset.left),
      separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
      separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
    ])
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func apply(item: Item, showSeparator: Bool, onTouchUser: @escaping ((User) -> Void)) {
    titleLabel.text = item.title.removingHTMLEntities()

    userButton.set(user: item.user)
    let identifier = UIAction.Identifier(rawValue: "user_action")

    userButton.removeAction(identifiedBy: identifier, for: .touchUpInside)
    let action = UIAction(identifier: identifier) { _ in
      onTouchUser(item.user)
    }
    userButton.addAction(action, for: .touchUpInside)

    separator.isHidden = !showSeparator
  }
}
