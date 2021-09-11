import UIKit
import FluxxKit
import RxSwift

final class SearchViewController: UIViewController {

  private let disposeBag = DisposeBag()
  private let navigator = Navigator.make()
  private let store = SearchViewModel.make()
  private let historyVC = HistoryViewController()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    Dispatcher.shared.unregister(store: self.navigator)
    Dispatcher.shared.unregister(store: self.store)
  }
}

// MARK: - lifecycle
extension SearchViewController: Navigatable {

  override func loadView() {
    super.loadView()
    minq.setTabBarItem(image: Icon.searchImage, title: L10n.search)
    navigationItem.titleView = UIImageView(
      image: Asset.Images.logo.image
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.isTranslucent = false

    setSearchController()

    Dispatcher.shared.register(store: store)
    Dispatcher.shared.register(store: navigator)
    navigator.state.bind(to: self, with: disposeBag)
    bind(store: store)

    minq.fill(with: historyVC)
  }

  func activate() {
    Dispatcher.shared.unregister(store: Navigator.NavigationStore.self)
    Dispatcher.shared.register(store: navigator)
  }
}

// MARK: - searchBar
extension SearchViewController: UISearchResultsUpdating, UISearchBarDelegate {
  func updateSearchResults(for searchController: UISearchController) {
    if let text = searchController.searchBar.text {
      Dispatcher.shared.dispatch(action: SearchViewModel.Action.updateQuery(query: text))
    }
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    minq.fill(with: historyVC)
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = navigationItem.searchController?.searchBar.text,
      query.count > 0 else { return }
    let itemQuery = ItemQuery(type: .search(string: query))
    let vc = ItemCollectionViewController(query: itemQuery, avoidCache: true)
    minq.fill(with: vc)
    AnalyticsService.log(event: .search)
  }

}

// MARK: - private
private extension SearchViewController {
  func setSearchController() {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchResultsUpdater = self
    searchController.searchBar.delegate = self
    searchController.searchBar.sizeToFit()
    searchController.searchBar.tintColor = Asset.Colors.blue.color
    searchController.searchBar.enablesReturnKeyAutomatically = true
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
  }

  func bind(store: SearchViewModel.SearchStore) {

    store.state.unfocusSignal.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.navigationItem.searchController?.searchBar.resignFirstResponder()
      }).disposed(by: disposeBag)

    store.state.query.asObserver()
      .distinctUntilChanged()
      .subscribeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] query in
        guard let searchBar = self?.navigationItem.searchController?.searchBar else { return }
        searchBar.text = query
      }).disposed(by: disposeBag)
  }
}
