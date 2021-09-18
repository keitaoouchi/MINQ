import UIKit
import FluxxKit
import RxSwift

final class SearchViewController: UIViewController {

  private let disposeBag = DisposeBag()
  private let navigator = Navigator.make()
  private let historyVC = HistoryViewController()

  init() {
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    deactivate()
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

    minq.baseLayout()

    setSearchController()

    Dispatcher.shared.register(store: navigator)
    navigator.state.bind(to: self, with: disposeBag)

    minq.fill(with: historyVC, adjustToSafeArea: true)
  }

  func activate() {
    Dispatcher.shared.unregister(store: Navigator.NavigationStore.self)
    Dispatcher.shared.register(store: navigator)
  }

  func deactivate() {
    navigationItem.searchController?.isActive = false
    Dispatcher.shared.unregister(store: self.navigator)
  }
}

// MARK: - searchBar
extension SearchViewController: UISearchBarDelegate {
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    minq.fill(with: historyVC)
  }

  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let query = navigationItem.searchController?.searchBar.text,
      query.count > 0 else { return }
    let itemQuery = ItemQuery(type: .search(string: query))
    let vc = ItemCollectionViewController(query: itemQuery, avoidCache: false)
    minq.fill(with: vc)
    AnalyticsService.log(event: .search)
  }
}

// MARK: - private
private extension SearchViewController {
  func setSearchController() {
    let searchController = UISearchController(searchResultsController: nil)
    searchController.obscuresBackgroundDuringPresentation = false
    searchController.searchBar.delegate = self
    searchController.searchBar.sizeToFit()
    searchController.searchBar.tintColor = Asset.Colors.blue.color
    searchController.searchBar.enablesReturnKeyAutomatically = true
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = false
    definesPresentationContext = true
  }
}
