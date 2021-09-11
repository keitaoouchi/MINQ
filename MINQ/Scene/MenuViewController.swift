import UIKit
import FluxxKit

final class MenuViewController: UITabBarController {

  override func viewDidLoad() {
    super.viewDidLoad()
    loadTabs()

    tabBar.isTranslucent = false
    tabBar.tintColor = Asset.Colors.green.color

    delegate = self

    if let item = self.tabBar.items?.first {
      tabBar(self.tabBar, didSelect: item)
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

    guard let currentIndex = tabBar.items?.firstIndex(of: item) else { return }
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
      HomeViewController(),
      SearchViewController(),
      SettingsViewController()
    ].map { UINavigationController(rootViewController: $0) }
    vcs.forEach {
      $0.view.backgroundColor = Asset.Colors.bg.color
      _ = $0.topViewController?.view
    }
    viewControllers = vcs
  }
}
