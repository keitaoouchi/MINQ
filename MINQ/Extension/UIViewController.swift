import UIKit

extension UIViewController: MINQExtensible {}

extension MINQExtension where Base: UIViewController {

  // 他の子ViewControllerを一掃して新たな子ViewControllerを追加して親Viewいっぱいに表示する
  func fill(with child: UIViewController, adjustToSafeArea: Bool = false) {
    self.base.children.forEach { vc in
      vc.removeFromParent()
      vc.view.removeFromSuperview()
    }
    self.base.addChild(child)
    self.base.view.minq.fill(with: child.view, adjustToSafeArea: adjustToSafeArea)
    child.didMove(toParent: self.base)
  }

  func setTabBarItem(image: UIImage, title: String) {
    self.base.navigationController?.tabBarItem.image = image
    self.base.navigationController?.tabBarItem.selectedImage = image
    self.base.navigationController?.tabBarItem.title = title
  }

  func hideComplementalStateView() {
    self.base.view.subviews.forEach { subView in
      if subView is ComplementalStateView {
        let animation = UIViewPropertyAnimator(duration: 0.33, curve: .easeInOut)
        animation.addAnimations({
          subView.alpha = 0.0
        })
        animation.addCompletion({ _ in
          subView.removeFromSuperview()
        })
        animation.startAnimation()
      }
    }
  }

  func baseLayout() {
    base.navigationController?.navigationBar.isTranslucent = true
    base.navigationController?.navigationBar.isOpaque = false
    base.edgesForExtendedLayout = [.top, .bottom]
    base.extendedLayoutIncludesOpaqueBars = true
  }
}
