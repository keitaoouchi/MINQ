import RxSwift
import FluxxKit
import UIKit
import SafariServices

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
  let tagStream = PublishSubject<Tag>()
  let itemStream = PublishSubject<ItemRecord>()
  let urlStream = PublishSubject<URL>()

  // MARK: - Action
  enum Link: ActionType {
    case user(user: User)
    case tag(tag: Tag)
    case item(item: ItemRecord)
    case url(url: URL)
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
      case .url(let url):
        state.urlStream.onNext(url)
      }
    }
  }
}

// MARK: - Binder
extension Navigator {
  func bind(to viewController: UIViewController, with disposer: DisposeBag) {
    self
      .userStream
      .subscribe(onNext: { [weak viewController] user in
        let query = ItemQuery(type: .user(user: user))
        let vc = ItemTableViewController.make(by: query)
        viewController?.navigationController?.pushViewController(vc, animated: true)
      }).disposed(by: disposer)

    self
      .tagStream
      .subscribe(onNext: { [weak viewController] tag in
        let query = ItemQuery(type: .tag(tag: tag))
        let vc = ItemTableViewController.make(by: query)
        viewController?.navigationController?.pushViewController(vc, animated: true)
        AnalyticsService.log(event: .viewItemsBy(tag: tag))
      }).disposed(by: disposer)

    self
      .itemStream
      .subscribe(onNext: { [weak viewController] item in
        let vc = ItemDetailViewController.make(for: item)
        viewController?.navigationController?.pushViewController(vc, animated: true)
        if let id = item.id {
          AnalyticsService.log(event: .viewItem(id: id))
        }
      }).disposed(by: disposer)

    self
      .urlStream
      .subscribe(onNext: { [weak viewController] url in
        let safari = SFSafariViewController(url: url)
        viewController?.navigationController?.viewControllers.first?.present(safari, animated: true, completion: nil)
      }).disposed(by: disposer)
  }
}
