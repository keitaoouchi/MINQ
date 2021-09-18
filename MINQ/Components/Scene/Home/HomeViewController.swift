import UIKit
import FluxxKit
import RxSwift
import RealmSwift
import Parchment

final class HomeViewController: UIViewController, Navigatable {
  private var queries: [ItemQuery.QueryType]!
  private var vcs: [ItemCollectionViewController]!
  private var menu: PagingViewController!
  private let navigator = Navigator.make()
  private let viewModel = HomeViewModel()
  private var channelObserver: Disposable?

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    deactivate()
  }

  override func loadView() {
    super.loadView()
    minq.setTabBarItem(image: Icon.homeImage, title: L10n.home)
    navigationItem.titleView = UIImageView(
      image: Asset.Images.logo.image
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    minq.baseLayout()
    setupNavigationItems()
    setVcs()
    setPagingViewController()

    bind(store: self.navigator)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    hidesBottomBarWhenPushed = true
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if viewModel.needsUpdate {
      channelObserver?.dispose()
      setVcs()
      menu.reloadData(around: pagingIndexItem(for: 0))
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    hidesBottomBarWhenPushed = false

    self.channelObserver = viewModel.observeWatchingTagsChanges()
  }

  func activate() {
    Dispatcher.shared.unregister(store: Navigator.NavigationStore.self)
    Dispatcher.shared.register(store: self.navigator)
  }

  func deactivate() {
    Dispatcher.shared.unregister(store: self.navigator)
    channelObserver?.dispose()
  }
}

// MARK: - MISC
private extension HomeViewController {
  func setupNavigationItems() {
    let editChannelImage = UIImage.fontAwesomeIcon(
      name: .broadcastTower,
      style: .solid,
      textColor: .secondaryLabel,
      size: CGSize(width: 30, height: 30)
    )
    let channelEditButton = UIBarButtonItem(
      image: editChannelImage,
      style: .done,
      target: self,
      action: #selector(onTapChannelEditButton)
    )
    navigationItem.rightBarButtonItem = channelEditButton
  }

  func setVcs() {
    let tags = WatchingTagRepository
      .findAllTagNames()
      .map { name -> ItemQuery.QueryType in
        let tag = ItemTag(name: name)
        return ItemQuery.QueryType.tag(tag: tag)
      }
    var queries = Array(tags)
    queries.insert(contentsOf: [
      .latest,
      .stocks,
      .mine
    ], at: 0)
    let vcs = queries.map { type -> ItemCollectionViewController in
      let vc = ItemCollectionViewController(query: ItemQuery(type: type), avoidCache: false)
      vc.title = type.title
      return vc
    }
    self.queries = queries
    self.vcs = vcs
  }

  @objc func onTapChannelEditButton() {
    let vc = ChannelsViewController()
    self.navigationController?.pushViewController(vc, animated: true)
  }

  func bind(store: Navigator.NavigationStore) {
    store.state.bind(to: self, with: viewModel.disposeBag)
  }
}

// MARK: - Parchment
extension HomeViewController: PagingViewControllerInfiniteDataSource {
  private func setPagingViewController() {
    let menu = PagingViewController()
    menu.infiniteDataSource = self
    menu.menuBackgroundColor = Asset.Colors.green.color
    menu.backgroundColor = Asset.Colors.green.color
    menu.selectedBackgroundColor = Asset.Colors.green.color
    menu.borderColor = .clear
    menu.indicatorColor = .clear
    menu.textColor = .white
    menu.selectedTextColor = .white
    menu.selectedFont = .systemFont(ofSize: 16, weight: .bold)
    menu.font = .systemFont(ofSize: 16, weight: .regular)
    menu.select(pagingItem: pagingIndexItem(for: 0))
    minq.fill(with: menu, adjustToSafeArea: true)
    self.menu = menu
  }

  private func pagingIndexItem(for index: Int) -> PagingIndexItem {
    var titleIndex = index % vcs.count
    if titleIndex < 0 {
      titleIndex = vcs.count + titleIndex
    }
    return PagingIndexItem(index: index, title: queries[titleIndex].title)
  }

  func pagingViewController(_: PagingViewController, viewControllerFor pagingItem: PagingItem) -> UIViewController {
    let item = pagingItem as! PagingIndexItem
    var index = item.index % vcs.count
    if index < 0 {
      index = vcs.count + index
    }
    return self.vcs[index]
  }

  func pagingViewController(_: PagingViewController, itemBefore pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! PagingIndexItem
    return pagingIndexItem(for: item.index - 1)
  }

  func pagingViewController(_: PagingViewController, itemAfter pagingItem: PagingItem) -> PagingItem? {
    let item = pagingItem as! PagingIndexItem
    return pagingIndexItem(for: item.index + 1)
  }
}
