import UIKit
import FluxxKit

final class MenuViewController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    self.loadTabs()

    self.tabBar.isTranslucent = false
    self.tabBar.tintColor = Asset.Colors.green.color

    self.delegate = self

    if let item = self.tabBar.items?.first {
      self.tabBar(self.tabBar, didSelect: item)
    }
  }
}

// MARK: - static
extension MenuViewController {
  static func make() -> MenuViewController {
    return MenuViewController()
  }
}

// MARK: - tabbar
extension MenuViewController: UITabBarControllerDelegate {

  override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

    guard let currentIndex = tabBar.items?.index(of: item) else { return }
    guard let vc = viewControllers?[currentIndex] else { return }
    guard let nav = vc as? UINavigationController else { return }
    if let top = nav.viewControllers.first as? Navigatable {
      top.activate()
    }
  }
}

// MARK: - private
private extension MenuViewController {
  // 各VCのviewを叩いてloadViewが呼び出されるようにする
  func loadTabs() {
    let vcs = [
      StoryboardScene.Home.initialScene.instantiate(),
      StoryboardScene.Search.initialScene.instantiate(),
      StoryboardScene.Settings.initialScene.instantiate()
    ]

    vcs.forEach { vc in
      _ = vc.topViewController?.view
    }
    self.viewControllers = vcs
  }
}
