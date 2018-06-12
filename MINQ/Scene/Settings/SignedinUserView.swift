import UIKit
import Reusable

final class SignedinUserView: UIView, NibOwnerLoadable {

  @IBOutlet private weak var userImage: UIImageView!
  @IBOutlet private weak var nameLabel: UILabel!

  func apply(user: User) {
    userImage.minq.circulize()
    userImage.kf.setImage(with: user.profileImageUrl?.minq_asURL)
    nameLabel.text = user.id
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.loadNibContent()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.loadNibContent()
  }
}
