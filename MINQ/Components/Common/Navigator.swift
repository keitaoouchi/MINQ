import RxSwift
import FluxxKit
import UIKit
import SafariServices

protocol Navigatable {
  func activate()
  func deactivate()
}

struct Navigator: StateType {

  typealias NavigationStore = Store<Navigator, Link>

  // MARK: - make
  static func make() -> Store<Navigator, Link> {
    return Store<Navigator, Link>(
      reducer: Navigator.StoreReducer()
    )
  }

  // MARK: - State
  let userStream = PublishSubject<User>()
  let tagStream = PublishSubject<ItemTag>()
  let itemStream = PublishSubject<Item>()
  let itemIdStream = PublishSubject<String>()
  let urlStream = PublishSubject<URL>()

  // MARK: - Action
  enum Link: ActionType {
    case user(_ user: User)
    case tag(_ tag: ItemTag)
    case item(_ item: Item)
    case itemId(_ itemId: String)
    case url(_ url: URL)
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<Navigator, Link> {
    override func reduce(state: Navigator, action: Navigator.Link) {
      switch action {
      case .user(let user):
        state.userStream.onNext(user)
      case .tag(let tag):
        state.tagStream.onNext(tag)
      case .item(let item):
        state.itemStream.onNext(item)
      case .itemId(let itemId):
        state.itemIdStream.onNext(itemId)
      case .url(let url):
        state.urlStream.onNext(url)
      }
    }
  }
}

// MARK: - Binder
extension Navigator {
  func bind(to viewController: UIViewController, with disposer: DisposeBag) {
    userStream
      .subscribe(onNext: { [weak viewController] user in
        let query = ItemQuery(type: .user(user: user))
        let vc = ItemCollectionViewController(query: query, avoidCache: false)
        viewController?.navigationController?.pushViewController(vc, animated: true)
      }).disposed(by: disposer)

    tagStream
      .subscribe(onNext: { [weak viewController] tag in
        let query = ItemQuery(type: .tag(tag: tag))
        let vc = ItemCollectionViewController(query: query, avoidCache: false)
        viewController?.navigationController?.pushViewController(vc, animated: true)
        AnalyticsService.log(event: .viewItemsBy(tag: tag))
      }).disposed(by: disposer)

    itemStream
      .subscribe(onNext: { [weak viewController] item in
        let vc = ItemDetailViewController.make(for: item)
        viewController?.navigationController?.pushViewController(vc, animated: true)
        AnalyticsService.log(event: .viewItem(id: item.id))

        // 詳細画面が破棄された時に評価値が変わっていたらレビュー依頼を出す
        let current = ReviewRequestService.shouldRequestReview
        _ = vc.rx.deallocating.take(until: vc.rx.deallocating).observe(on: MainScheduler.instance).subscribe { _ in
          if ReviewRequestService.shouldRequestReview != current {
            ReviewRequestService.request()
          }
        }
      }).disposed(by: disposer)

    itemIdStream
      .flatMap { ItemRepository.find(by: $0) }
      .subscribe(onNext: { item in
        itemStream.onNext(item)
      }, onError: { error in
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.show(message: .alert(message: error.localizedDescription)))
      }).disposed(by: disposer)

    urlStream
      .subscribe(onNext: { [weak viewController] url in
        guard let scheme = url.scheme, scheme == "http" || scheme == "https" else { return }

        let safari = SFSafariViewController(url: url)
        viewController?.navigationController?.viewControllers.first?.present(safari, animated: true, completion: nil)
      }).disposed(by: disposer)
  }
}
