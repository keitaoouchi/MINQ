import UIKit
import FluxxKit
import RxSwift
import RealmSwift
import PagingMenuController

final class HomeViewController: UIViewController, Navigatable {

  private let menuRecord: MenuRecord = MenuRecord.instance
  private var menuItems: [ItemQuery.QueryType]!
  private var vcs: [ItemTableViewController]!
  private let navigator = Navigator.make()
  private let disposeBag = DisposeBag()
  private var notificationToken: NotificationToken?
  private var pagingMenu: PagingMenuController!

  deinit {
    self.notificationToken?.invalidate()
    Dispatcher.shared.unregister(store: self.navigator)
  }

  override func loadView() {
    super.loadView()
    self.minq.setTabBarItem(image: AppInfo.homeImage, title: "ホーム")
    self.navigationItem.titleView = UIImageView(
      image: Asset.Images.logoDeepGreen.image
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setupNavigationItems()
    self.setTables()
    self.pagingMenu = PagingMenuController(
      options: MINQMenu(vcs: self.vcs)
    )

    self.minq.fill(with: self.pagingMenu)
    self.pagingMenu.move(toPage: 1)
    self.pagingMenu.move(toPage: 0)

    self.notificationToken = self.menuRecord.observe { [weak self] _ in
      guard let _self = self else { return }
      _self.setTables()
      _self.pagingMenu.setup(MINQMenu(vcs: _self.vcs))
      _self.pagingMenu.move(toPage: 1)
      _self.pagingMenu.move(toPage: 0)
    }

    self.bind(store: self.navigator)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hidesBottomBarWhenPushed = true
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    hidesBottomBarWhenPushed = false
  }

  func activate() {
    Dispatcher.shared.unregister(store: Navigator.NavigationStore.self)
    Dispatcher.shared.register(store: self.navigator)
  }

}

// MARK: - private
private extension HomeViewController {

  func setTables() {
    self.menuItems = [
      .latest,
      .stocks,
      .mine
    ]
    self.menuRecord.tags.forEach { tagRecord in
      if let name = tagRecord.name {
        let tag = Tag(name: name)
        let query = ItemQuery.QueryType.tag(tag: tag)
        self.menuItems.append(query)
      }
    }
    self.vcs = menuItems.map { type -> ItemTableViewController in
      let vc = ItemTableViewController.make(by: ItemQuery(type: type))
      return vc
    }
  }

  func setupNavigationItems() {
    let editChannelImage = UIImage.fontAwesomeIcon(
      name: .flash,
      textColor: Asset.Colors.gray.color,
      size: CGSize(width: 30, height: 30)
    )
    let editChannelButton = UIBarButtonItem(
      image: editChannelImage,
      style: UIBarButtonItemStyle.done,
      target: self,
      action: #selector(onTapEditMenuButton)
    )
    navigationItem.rightBarButtonItem = editChannelButton
  }

  @objc func onTapEditMenuButton() {
    let vc = StoryboardScene.MenuEdit.initialScene.instantiate()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func bind(store: Navigator.NavigationStore) {
    store.state.bind(to: self, with: self.disposeBag)
  }
}
