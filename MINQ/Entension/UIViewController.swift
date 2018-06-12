import UIKit

extension UIViewController: MINQExtensible {}

extension MINQExtension where Base: UIViewController {

  // 他の子ViewControllerを一掃して新たな子ViewControllerを追加して親Viewいっぱいに表示する
  func fill(with childViewController: UIViewController, handler: (() -> Void)? = nil) {
    self.base.childViewControllers.forEach { vc in
      vc.removeFromParentViewController()
      vc.view.removeFromSuperview()
    }
    self.base.view.minq.fill(with: UIView())
    self.base.addChildViewController(childViewController)
    self.base.view.minq.fill(with: childViewController.view)
    childViewController.didMove(toParentViewController: self.base)
  }

  func setTabBarItem(image: UIImage, title: String) {
    self.base.navigationController?.tabBarItem.image = image
    self.base.navigationController?.tabBarItem.selectedImage = image
    self.base.navigationController?.tabBarItem.title = title
  }

}
