import UIKit
import FluxxKit

final class TagsView: UIView {
  private let leadingTag: UILabel = {
    let label = UILabel()
    label.font = Style.FontAwesome.tagMark
    label.text = String.fontAwesomeIcon(name: .tags)
    label.textAlignment = .center
    label.textColor = .secondaryLabel.withAlphaComponent(0.3)
    label.textAlignment = .center
    label.widthAnchor.constraint(equalToConstant: 24).isActive = true
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()

  private let stackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 8.0
    return stack
  }()

  convenience init(tags: [ItemTag]) {
    self.init()

    apply(tags: tags)
  }

  init() {
    super.init(frame: .zero)

    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = false
    scrollView.showsHorizontalScrollIndicator = false

    minq.fill(with: scrollView)
    scrollView.minq.fill(with: stackView)
    stackView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
  }

  func apply(tags: [ItemTag]) {
    stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    stackView.addArrangedSubview(leadingTag)
    tags.forEach { tag in
      let button = UIButton(type: .custom)
      button.titleLabel?.font = Style.Font.tag
      button.titleLabel?.textColor = .secondaryLabel
      let title = NSAttributedString(
        string: tag.name,
        attributes: [
          NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
      )
      button.setAttributedTitle(title, for: .normal)
      button.addAction(.init(handler: { _ in
        Dispatcher.shared.dispatch(action: Navigator.Link.tag(tag))
      }), for: .touchUpInside)
      stackView.addArrangedSubview(button)
    }
  }

  override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: 40.0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
