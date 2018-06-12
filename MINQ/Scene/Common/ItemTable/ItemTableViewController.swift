import UIKit
import RxSwift
import RealmSwift
import FluxxKit

final class ItemTableViewController: UITableViewController {

  private(set) var query: ItemQuery!
  private var results: Results<ItemRecord>!
  private var store: ItemTableViewModel.ItemTableStore!
  private var actionCreator: ItemTableViewModel.AsyncActionCreator!
  private var notificationToken: NotificationToken?
  private let disposeBag = DisposeBag()

  deinit {
    self.notificationToken?.invalidate()
    Dispatcher.shared.unregister(store: self.store)
  }
}

// MARK: - static
extension ItemTableViewController {

  static func make(by query: ItemQuery) -> ItemTableViewController {
    let vc = StoryboardScene.ItemTable.itemTable.instantiate()
    vc.query = query
    vc.results = try! ItemCollectionRecord.findOrCreate(
      of: query.type).items.filter(NSPredicate(value: true))
    let store = ItemTableViewModel.make()
    let actionCreator = ItemTableViewModel.AsyncActionCreator(
      store: store,
      query: query
    )
    vc.store = store
    vc.actionCreator = actionCreator
    return vc
  }
}

// MARK: - lifecycles
extension ItemTableViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    self.title = self.query.type.title

    self.setupUI()

    self.setupNavigationItem()

    Dispatcher.shared.register(store: self.store)

    self.bind(store: store)
    self.bind(results: self.results, to: self.store)
    self.bind(authStored: Authentication.isStored.asObservable().skip(1))

    self.start()
  }
}

extension ItemTableViewController: Startable {
  func start() {
    try? self.actionCreator.load()
  }
}

// MARK: - delegate && datasource
extension ItemTableViewController {

  override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return .leastNormalMagnitude
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return results.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    if indexPath.row == (results.count - 2) {
      self.actionCreator.paginate()
    }

    let itemRecord = results[indexPath.row]

    let cell = tableView.dequeueReusableCell(for: indexPath) as ItemTableCell
    if let item = Item(record: itemRecord) {
      cell.apply(item: item)
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let itemRecord = results[indexPath.row]
    Dispatcher.shared.dispatch(action: Navigator.Link.item(item: itemRecord))
  }

}

// MARK: - private
private extension ItemTableViewController {

  func bind(results: Results<ItemRecord>, to store: StoreType) {
    self.notificationToken?.invalidate()
    self.notificationToken = ResultsState.bind(
      results: results,
      to: store,
      onChange: { [weak self] changes in
        self?.minq.apply(changes: changes)
      },
      onEmpty: { store in
        store.dispatch(action: ItemTableViewModel.Transition.results(to: .empty))
      },
      onFulfilled: { store in
        store.dispatch(action: ItemTableViewModel.Transition.results(to: .fulfilled))
      }
    )
  }

  func bind(store: ItemTableViewModel.ItemTableStore) {
    store
      .state
      .viewState
      .distinctUntilChanged()
      .asObservable()
      .subscribe(onNext: { [weak self] state in
        self?.minq.apply(status: state, onReload: { _ in
          self?.actionCreator.reload()
        })
      }).disposed(by: self.disposeBag)
  }

  func bind(authStored: Observable<Bool>) {
    authStored.subscribe(onNext: { [weak self] _ in
      self?.store.dispatch(action: ItemTableViewModel.Transition.request(to: .initial))
      self?.actionCreator.reload()
    }).disposed(by: self.disposeBag)
  }

  @objc func refresh() {
    self.actionCreator.reload()
  }

  func setupUI() {
    self.tableView.refreshControl = UIRefreshControl()
    self.tableView.refreshControl?.addTarget(self,
                                             action: #selector(refresh),
                                             for: .valueChanged)
  }

  // TODO: 単方向データフローじゃないので変える
  func setupNavigationItem() {
    guard self.navigationController != nil else { return }

    switch query.type {
    case .tag(let tag):
      if MenuRecord.instance.contains(tag: tag) {
        navigationItem.rightBarButtonItem =
          UIBarButtonItem(barButtonSystemItem: .trash,
                          target: self,
                          action: #selector(removeTag))
      } else {
        navigationItem.rightBarButtonItem =
          UIBarButtonItem(barButtonSystemItem: .add,
                          target: self,
                          action: #selector(addTag))
      }
    default:
      break
    }
  }

  @objc func removeTag() {
    switch query.type {
    case .tag(let tag):
      try? MenuRecord.instance.remove(named: tag.name)
      setupNavigationItem()
    default: ()
    }
  }

  @objc func addTag() {
    switch query.type {
    case .tag(let tag):
      try? MenuRecord.instance.append(tag: tag)
      setupNavigationItem()
    default: ()
    }
  }
}
