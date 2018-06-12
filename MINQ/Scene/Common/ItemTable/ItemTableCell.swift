import UIKit
import Kingfisher
import FontAwesome
import RxCocoa
import RxSwift
import Reusable
import FluxxKit

final class ItemTableCell: UITableViewCell, Reusable {

  @IBOutlet weak var articleTitleLabel: UILabel!
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userButton: UIButton!

  @IBOutlet weak var commentMarkLabel: UILabel!
  @IBOutlet weak var commentCountLabel: UILabel!

  @IBOutlet weak var likesMarkLabel: UILabel!
  @IBOutlet weak var likesCountLabel: UILabel!
  @IBOutlet weak var tagsStackView: UIStackView!
  @IBOutlet weak var tagsScroller: UIScrollView!

  var userTouched: ((User) -> Void)?
  var tagTouched: ((Tag) -> Void)?

  var userButtonSubscription: Disposable?

  private let textAttributes = [NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]

  deinit {
    userButtonSubscription?.dispose()
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    tagsScroller.scrollsToTop = false
    commentMarkLabel.font = UIFont.fontAwesome(ofSize: AppInfo.commentMarkSize)
    commentMarkLabel.text = String.fontAwesomeIcon(name: .commentsO)
    likesMarkLabel.font = UIFont.fontAwesome(ofSize: AppInfo.stockMarkSize)
    likesMarkLabel.text = String.fontAwesomeIcon(name: .thumbsOUp)
    tagsStackView.backgroundColor = .white
    self.layoutIfNeeded()
  }

  func apply(item: Item) {
    userNameLabel.text = item.user.id
    articleTitleLabel.text = item.title.removingHTMLEntities
    likesCountLabel.text = "\(item.likesCount)"
    commentCountLabel.text = "\(item.commentsCount)"
    self.tagsScroller.scrollsToTop = false
    self.tagsStackView.minq.arrangeTags(of: item)
    userImage.minq.circulize()
    userImage.kf.setImage(with: item.user.profileImageUrl?.minq_asURL)

    self.userButtonSubscription?.dispose()
    self.userButtonSubscription = userButton.rx.tap.asDriver().drive(onNext: { _ in
      Dispatcher.shared.dispatch(
        action: Navigator.Link.user(user: item.user))
    })
  }

}
