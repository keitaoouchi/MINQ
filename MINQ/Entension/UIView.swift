import UIKit
import Reusable

extension UIView: MINQExtensible {}

extension MINQExtension where Base: UIView {

  func fill(with childView: UIView?) {
    guard let childView = childView else { return }
    guard !self.base.subviews.contains(childView) else { return }

    self.base.subviews.forEach { subView in
      subView.removeFromSuperview()
    }
    self.attach(childView)
  }

  func attach(_ childView: UIView) {
    self.base.addSubview(childView)
    childView.translatesAutoresizingMaskIntoConstraints = false
    childView.topAnchor.constraint(equalTo: self.base.topAnchor).isActive = true
    childView.leadingAnchor.constraint(equalTo: self.base.leadingAnchor).isActive = true
    childView.trailingAnchor.constraint(equalTo: self.base.trailingAnchor).isActive = true
    childView.bottomAnchor.constraint(equalTo: self.base.bottomAnchor).isActive = true
  }
}
