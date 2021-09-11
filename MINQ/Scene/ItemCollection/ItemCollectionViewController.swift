import UIKit
import RxSwift
import RealmSwift
import FluxxKit
import Reusable

final class ItemCollectionViewController: UICollectionViewController {
  private lazy var dataSource = DataSource(
    collectionView: collectionView,
    cellProvider: Self.cellProvider)
  private let viewModel: ItemCollectionViewModel
  private let disposeBag = DisposeBag()
  private let avoidCache: Bool

  deinit {
    Dispatcher.shared.unregister(store: viewModel.store)
  }

  init(query: ItemQuery, avoidCache: Bool) {
    self.avoidCache = avoidCache
    viewModel = ItemCollectionViewModel(query: query)
    super.init(collectionViewLayout: ItemCollectionViewController.layout)
    title = viewModel.query.type.title
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - lifecycles
extension ItemCollectionViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    configureUI()

    Dispatcher.shared.register(store: viewModel.store)

    bind(to: viewModel.store.state)
    bind(authStored: AuthenticationRepository.storing.asObservable().skip(1))

    viewModel.start(avoidCache: avoidCache)
  }
}

// MARK: - Layout & UISettings

extension ItemCollectionViewController {
  func configureUI() {
    collectionView.register(cellType: ItemCollectionCell.self)
    collectionView.register(cellType: LoadingCell.self)
    collectionView.register(cellType: ReloadableFooterCell.self)
    collectionView.register(supplementaryViewType: HorizontalBorder.self, ofKind: ElementKind.border.rawValue)
    collectionView.refreshControl = UIRefreshControl()
    collectionView.refreshControl?.tintColor = Asset.Colors.green.color
    collectionView.refreshControl?.addTarget(self,
                                             action: #selector(refresh),
                                             for: .valueChanged)
    collectionView.backgroundColor = Asset.Colors.bg.color
    var snapshot = dataSource.snapshot()
    snapshot.appendSections([.main])
    dataSource.apply(snapshot)
    dataSource.supplementaryViewProvider = Self.supplementaryViewProvider
  }

  static var layout: UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(44))
    let borderSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(0.5))
    let borderAnchor = NSCollectionLayoutAnchor(
      edges: [.leading, .bottom],
      absoluteOffset: CGPoint(x: Style.Margin.itemCollection.left, y: 0))
    let border = NSCollectionLayoutSupplementaryItem(
      layoutSize: borderSize,
      elementKind: ElementKind.border.rawValue,
      containerAnchor: borderAnchor)
    let item = NSCollectionLayoutItem(layoutSize: itemSize, supplementaryItems: [border])
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: itemSize,
      subitem: item,
      count: 1)
    let section = NSCollectionLayoutSection(group: group)
    let layout = UICollectionViewCompositionalLayout(section: section)
    return layout
  }

  static let cellProvider: DataSource.CellProvider = { collectionView, indexPath, content in
    switch content {
    case .item(let identifier):
      guard let item = ItemRepository.findCached(by: identifier) else {
        return collectionView.dequeueReusableCell(for: indexPath) as ItemCollectionCell
      }
      return collectionView.dequeueConfiguredReusableCell(using: ItemCollectionViewController.cellRegistration, for: indexPath, item: item)
    case .paginating:
      return collectionView.dequeueReusableCell(for: indexPath) as LoadingCell
    case .failed:
      let cell = collectionView.dequeueReusableCell(for: indexPath) as ReloadableFooterCell
      cell.reloadableFooterView.setErrorMessage(L10n.loadError, color: Asset.Colors.red.color)
      return cell
    case .cacheLoaded:
      let cell = collectionView.dequeueReusableCell(for: indexPath) as ReloadableFooterCell
      cell.reloadableFooterView.setErrorMessage(L10n.cacheLoaded, color: Asset.Colors.yellow.color)
      return cell
    }
  }

  static let supplementaryViewProvider: DataSource.SupplementaryViewProvider = { collectionView, elementKind, indexPath in
    if elementKind == ElementKind.border.rawValue {
      let view = collectionView.dequeueConfiguredReusableSupplementary(using: borderRegistration, for: indexPath)
      view.backgroundColor = indexPath.isTail(in: collectionView) ? .clear : .separator
      return view
    } else {
      return nil
    }
  }

  static let borderRegistration = UICollectionView.SupplementaryRegistration<HorizontalBorder>(
    elementKind: UICollectionView.elementKindSectionHeader) { _, _, _ in
    // no configuration
  }

  static let cellRegistration = UICollectionView.CellRegistration<ItemCollectionCell, Item> { cell, _, item in
    cell.apply(item: item)
  }
}

extension ItemCollectionViewController {

  override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    if indexPath.row == dataSource.snapshot().numberOfItems(inSection: .main) - 1 {
      viewModel.actionCreator.paginate(force: false)
    }
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collectionView.deselectItem(at: indexPath, animated: true)
    guard let content = dataSource.itemIdentifier(for: indexPath) else { return }

    switch content {
    case .cacheLoaded:
      // scrollToTop(animated: true)
      viewModel.actionCreator.reload()
    case .failed:
      viewModel.actionCreator.restore()
    case .item(let identifier):
      guard let item = ItemRepository.findCached(by: identifier) else { return }
      Dispatcher.shared.dispatch(
        action: Navigator.Link.item(item))
    case .paginating:
      break
    }
  }
}

// MARK: - Bindings
private extension ItemCollectionViewController {
  func bind(to state: ItemCollectionState) {
    state
      .requestState
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
      .asObservable()
      .subscribe(onNext: { [weak self] state in
        self?.show(status: state)
      }).disposed(by: disposeBag)

    state
      .watchingState
      .distinctUntilChanged()
      .observeOn(MainScheduler.instance)
      .asObservable()
      .subscribe(onNext: { [weak self] state in
        self?.updateNavigationItem(by: state)
      }).disposed(by: disposeBag)
  }

  func bind(authStored: Observable<Bool>) {
    authStored.observeOn(MainScheduler.instance).subscribe(onNext: { [weak self] _ in
      self?.viewModel.store.dispatch(action: ItemCollectionState.Mutate.requestState(to: .initial))
      self?.viewModel.actionCreator.reload()
    }).disposed(by: disposeBag)
  }
}

// MARK: - State Presentation

private extension ItemCollectionViewController {
  func show(status: RequestState) {
    switch status {
    case .initial:
      showInitial()
    case .authRequired:
      showAuthRequired()
    case .requesting(let type):
      showLoading(type)
    case .failed(_, let pagingState):
      collectionView.refreshControl?.endRefreshing()
      showError(pagingState)
    case .empty:
      collectionView.refreshControl?.endRefreshing()
      showEmpty()
    case .done:
      collectionView.refreshControl?.endRefreshing()
      minq.hideComplementalStateView()
    case .loaded(let pagingState, let identifiers):
      showContents(identifiers, pagingState: pagingState)
    }
  }

  func showContents(_ identifiers: [String], pagingState: PagingState) {
    var snapshot = dataSource.snapshot(for: .main)
    let animation = !snapshot.items.isEmpty
    snapshot.deleteAll()
    let contents = identifiers.map { Content.item($0) }
    snapshot.deleteItemsIfExists([.paginating, .cacheLoaded])
    snapshot.append(contents)
    if pagingState == .fromCached {
      snapshot.append([.cacheLoaded])
    }
    dataSource.apply(
      snapshot,
      to: .main,
      animatingDifferences: animation,
      completion: nil)
  }

  func showInitial() {
    view.minq.removeComplementalStateView()
    let initial = InitialStateView()
    view.minq.fill(with: initial)
  }

  func showEmpty() {
    view.minq.removeComplementalStateView()
    let empty = EmptyStateView.loadFromNib()
    empty.onTapReloader = { [weak self] _ in
      self?.viewModel.actionCreator.restore()
    }
    view.minq.fill(with: empty)
  }

  func showLoading(_ type: RequestType) {
    switch type {
    case .normal:
      view.minq.removeComplementalStateView()
      let loader = LoadingStateView(style: .large)
      view.minq.fill(with: loader)
    case .pagination:
      var snapshot = dataSource.snapshot(for: .main)
      snapshot.deleteItemsIfExists([.failed, .cacheLoaded, .paginating])
      snapshot.append([.paginating])
      dataSource.apply(snapshot, to: .main, animatingDifferences: true, completion: nil)
    case .pullToRefresh:
      var snapshot = dataSource.snapshot(for: .main)
      guard snapshot.contains(.failed) || snapshot.contains(.cacheLoaded) else { return }
      snapshot.deleteItemsIfExists([.failed, .cacheLoaded, .paginating])
      snapshot.append([.paginating])
      dataSource.apply(snapshot, to: .main, animatingDifferences: true, completion: nil)
    }

  }

  func showAuthRequired() {
    showContents([], pagingState: .noPage)
    view.minq.removeComplementalStateView()
    let authView = AuthRequiredView.loadFromNib()
    view.minq.fill(with: authView)
  }

  func showError(_ pagingState: PagingState) {
    if pagingState.isPageOne && dataSource.snapshot(for: .main).items.isEmpty {
      view.minq.removeComplementalStateView()
      let failed = FailedStateView.loadFromNib()
      failed.onTapReloader = { [weak self] _ in
        self?.viewModel.actionCreator.restore()
      }
      view.minq.fill(with: failed)
    } else {
      var snapshot = dataSource.snapshot(for: .main)
      snapshot.deleteItemsIfExists([.failed, .cacheLoaded, .paginating])
      snapshot.append([.failed])
      dataSource.apply(snapshot, to: .main, animatingDifferences: true, completion: nil)
    }
  }

  func updateNavigationItem(by state: WatchingState) {
    switch state {
    case .unknown:
      break
    case .watching:
      navigationItem.rightBarButtonItem =
        UIBarButtonItem(barButtonSystemItem: .trash,
                        target: self,
                        action: #selector(removeTag))
    case .notWatching:
      navigationItem.rightBarButtonItem =
        UIBarButtonItem(barButtonSystemItem: .add,
                        target: self,
                        action: #selector(addTag))
    }
  }
}

// MARK: - Actions

extension ItemCollectionViewController {
  @objc func refresh() {
    viewModel.actionCreator.reload()
  }

  @objc func removeTag() {
    viewModel.actionCreator.removeTag()
  }

  @objc func addTag() {
    viewModel.actionCreator.addTag()
  }
}

// MARK: - MISC

extension ItemCollectionViewController {
  // コンテンツがあればトップ位置までスクロールさせる
  func scrollToTop(animated: Bool) {
    if collectionView.numberOfItems(inSection: 0) > 0 {
      let index = IndexPath(row: 0, section: 0)
      collectionView.scrollToItem(at: index, at: .top, animated: animated)
    }
  }
}

// MARK: - Related Types
extension ItemCollectionViewController {
  enum Section {
    case main
  }

  enum Content: Hashable {
    static func == (lhs: Content, rhs: Content) -> Bool {
      switch (lhs, rhs) {
      case (.paginating, .paginating): return true
      case (.failed, .failed): return true
      case (.cacheLoaded, .cacheLoaded): return true
      case (.item(let l), .item(let r)): return l == r
      default: return false
      }
    }

    case item(_ identifier: String)
    case paginating
    case failed
    case cacheLoaded
  }

  enum ElementKind: String {
    case border
  }

  typealias DataSource = UICollectionViewDiffableDataSource<Section, Content>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Content>
}

private extension NSDiffableDataSourceSectionSnapshot {
  mutating func deleteItemsIfExists(_ identifiers: [ItemIdentifierType]) {
    let existings = identifiers.filter { items.contains($0) }
    delete(existings)
  }
}
