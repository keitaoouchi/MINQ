import UIKit
import Reusable

final class TagCell: UITableViewCell, NibReusable {
  @IBOutlet weak var nameLabel: UILabel!

  func apply(tag: Tag) {
    self.nameLabel.text = tag.name
  }
}
