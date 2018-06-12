import UIKit
import Reusable

final class HistoryCell: UITableViewCell, Reusable {
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var userImage: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!

  func apply(record: ItemRecord) {
    userNameLabel.text = record.user?.id
    titleLabel.text = record.title?.removingHTMLEntities
    userImage.minq.circulize()
    userImage.kf.setImage(with: record.user?.profileImageUrl?.minq_asURL)
  }
}
