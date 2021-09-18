import UIKit
import FluxxKit

final class StatsView: UIView {
  private var item: Item?

  private let userButton: UserButton = {
    let button = UserButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()

  private let commentMark: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Style.FontAwesome.commentMark
    label.text = String.fontAwesomeIcon(name: .comments)
    label.textColor = .secondaryLabel
    return label
  }()

  private let commentCount: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Style.Font.stats
    label.text = "0"
    label.textColor = .secondaryLabel
    return label
  }()

  private let likesMark: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Style.FontAwesome.stockMark
    label.text = String.fontAwesomeIcon(name: .thumbsUp)
    label.textColor = .secondaryLabel
    return label
  }()

  private let likesCount: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = Style.Font.stats
    label.text = "0"
    label.textColor = .secondaryLabel
    return label
  }()

  convenience init() {
    self.init(frame: .zero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var intrinsicContentSize: CGSize {
    CGSize(width: UIView.noIntrinsicMetric, height: 32)
  }
}

extension StatsView {
  func apply(item: Item) {
    self.item = item
    userButton.set(user: item.user)
    likesCount.text = "\(item.likesCount)"
    commentCount.text = "\(item.commentsCount)"
  }

  private func setup() {
    addSubview(userButton)

    NSLayoutConstraint.activate([
      userButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      userButton.topAnchor.constraint(equalTo: topAnchor),
      userButton.bottomAnchor.constraint(equalTo: bottomAnchor)
    ])

    addSubview(likesMark)
    addSubview(likesCount)
    addSubview(commentMark)
    addSubview(commentCount)
    NSLayoutConstraint.activate([
      likesMark.leadingAnchor.constraint(equalTo: userButton.trailingAnchor),
      likesMark.topAnchor.constraint(equalTo: topAnchor),
      likesMark.bottomAnchor.constraint(equalTo: bottomAnchor),
      likesCount.leadingAnchor.constraint(equalTo: likesMark.trailingAnchor, constant: 12),
      likesCount.topAnchor.constraint(equalTo: topAnchor),
      likesCount.bottomAnchor.constraint(equalTo: bottomAnchor),
      commentMark.leadingAnchor.constraint(equalTo: likesCount.trailingAnchor, constant: 24),
      commentMark.topAnchor.constraint(equalTo: topAnchor),
      commentMark.bottomAnchor.constraint(equalTo: bottomAnchor),
      commentCount.leadingAnchor.constraint(equalTo: commentMark.trailingAnchor, constant: 12),
      commentCount.topAnchor.constraint(equalTo: topAnchor),
      commentCount.bottomAnchor.constraint(equalTo: bottomAnchor),
      commentCount.trailingAnchor.constraint(equalTo: trailingAnchor)
    ])

    _ = userButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] _ in
      guard let item = self?.item else { return }
      Dispatcher.shared.dispatch(
        action: Navigator.Link.user(item.user))
    })
  }
}
