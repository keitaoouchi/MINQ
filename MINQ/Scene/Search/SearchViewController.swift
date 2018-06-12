import UIKit
import FluxxKit
import RxSwift

final class SearchViewController: UIViewController {

  private let disposeBag = DisposeBag()
  private let navigator = Navigator.make()
  private let store = SearchViewModel.make()
  private let historyVC = HistoryViewController.make()

  deinit {
    Dispatcher.shared.unregister(store: self.navigator)
    Dispatcher.shared.unregister(store: self.store)
  }
}

// MARK: - lifecycle
extension SearchViewController: Navigatable {

  override func loadView() {
    super.loadView()
    self.minq.setTabBarItem(image: AppInfo.searchImage, title: "検索")
    self.navigationItem.titleView = UIImageView(
      image: Asset.Images.logoDeepGreen.image
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.setSearchController()

    Dispatcher.shared.register(store: self.store)
    Dispatcher.shared.register(store: self.navigator)
    self.navigator.state.bind(to: self, with: self.disposeBag)
    self.bind(store: self.store)

    self.minq.fill(with: self.historyVC)
  }

  func activate() {
    Dispatcher.shared.unregister(store: Navigator.NavigationStore.self)
    Dispatcher.shared.register(store: self.navigator)
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
    self.minq.fill(with: self.historyVC)
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = self.navigationItem.searchController?.searchBar.text,
      query.count > 0 else { return }
    let itemQuery = ItemQuery(type: .search(string: query))
    let vc = ItemTableViewController.make(by: itemQuery)
    self.minq.fill(with: vc)
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
    self.definesPresentationContext = true
  }

  func bind(store: SearchViewModel.SearchStore) {

    self.store.state.unfocusSignal.asDriver(onErrorJustReturn: ())
      .drive(onNext: { [weak self] in
        self?.navigationItem.searchController?.searchBar.resignFirstResponder()
      }).disposed(by: self.disposeBag)

    self.store.state.query.asObserver()
      .distinctUntilChanged()
      .subscribeOn(MainScheduler.instance)
      .subscribe(onNext: { [weak self] query in
        guard let searchBar = self?.navigationItem.searchController?.searchBar else { return }
        searchBar.text = query
      }).disposed(by: self.disposeBag)
  }
}
