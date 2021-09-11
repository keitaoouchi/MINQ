import UIKit
import Reusable

extension UIView: MINQExtensible {}

extension MINQExtension where Base: UIView {

  func fill(with childView: UIView?, clean: Bool = false) {
    guard let childView = childView else { return }
    guard !self.base.subviews.contains(childView) else { return }
    if clean {
      base.subviews.forEach { $0.removeFromSuperview() }
    }
    self.attach(childView)
  }

  func attach(_ childView: UIView, top: CGFloat? = nil, leading: CGFloat? = nil, trailing: CGFloat? = nil, bottom: CGFloat? = nil) {
    self.base.addSubview(childView)
    childView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      childView.topAnchor.constraint(equalTo: self.base.topAnchor, constant: top ?? 0),
      childView.leadingAnchor.constraint(equalTo: self.base.leadingAnchor, constant: leading ?? 0),
      childView.trailingAnchor.constraint(equalTo: self.base.trailingAnchor, constant: trailing ?? 0),
      childView.bottomAnchor.constraint(equalTo: self.base.bottomAnchor, constant: bottom ?? 0)
    ])
  }

  func centered(with childView: UIView) {
    base.addSubview(childView)
    childView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      childView.centerXAnchor.constraint(equalTo: base.centerXAnchor),
      childView.centerYAnchor.constraint(equalTo: base.centerYAnchor),
      childView.leadingAnchor.constraint(greaterThanOrEqualTo: base.leadingAnchor, constant: 16),
      childView.trailingAnchor.constraint(greaterThanOrEqualTo: base.trailingAnchor, constant: 16)
    ])
  }

  func removeComplementalStateView() {
    base.subviews.forEach { subView in
      if subView is ComplementalStateView {
        subView.removeFromSuperview()
      }
    }
  }
}
