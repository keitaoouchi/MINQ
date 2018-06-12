import UIKit

extension MINQExtension where Base: UIImageView {

  func circulize() {
    self.base.layer.cornerRadius = self.base.frame.height / 2
    self.base.layer.masksToBounds = true
    self.base.contentMode = UIViewContentMode.scaleAspectFill
    self.base.setNeedsLayout()
  }

}
