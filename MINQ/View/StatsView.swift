import UIKit
import Reusable
import FluxxKit

final class StatsView: UIView, NibLoadable {
  var item: Item?

  private let userButton = UserButton()

  @IBOutlet weak var commentMarkLabel: UILabel!
  @IBOutlet weak var commentCountLabel: UILabel!

  @IBOutlet weak var likesMarkLabel: UILabel!
  @IBOutlet weak var likesCountLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()

    addSubview(userButton)
    userButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      userButton.leadingAnchor.constraint(equalTo: leadingAnchor),
      userButton.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])

    commentMarkLabel.font = Style.FontAwesome.commentMark
    commentMarkLabel.text = String.fontAwesomeIcon(name: .comments)
    likesMarkLabel.font = Style.FontAwesome.stockMark
    likesMarkLabel.text = String.fontAwesomeIcon(name: .thumbsUp)

    _ = userButton.rx.controlEvent(.touchUpInside).asDriver().drive(onNext: { [weak self] _ in
      guard let item = self?.item else { return }
      Dispatcher.shared.dispatch(
        action: Navigator.Link.user(item.user))
    })
  }

  func apply(item: Item) {
    self.item = item
    userButton.set(user: item.user)
    likesCountLabel.text = "\(item.likesCount)"
    commentCountLabel.text = "\(item.commentsCount)"
  }
}
