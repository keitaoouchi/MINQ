import UIKit
import RxSwift
import FluxxKit
import RealmSwift

final class MenuEditViewController: UIViewController {

  @IBOutlet private weak var currentTagsContainer: UIView!
  @IBOutlet private weak var followingTagsContainer: UIView!
  @IBOutlet private weak var currentTagsHeight: NSLayoutConstraint!
  @IBOutlet private weak var followingTagsHeight: NSLayoutConstraint!

  private let store = MenuEditViewModel.make()
  private lazy var actionCreator = MenuEditViewModel.ActionCreator(store: self.store)

  private let currentTagsVC: CurrentTagsViewController = CurrentTagsViewController.make()
  private let followingTagsVC: FollowingTagsViewController = FollowingTagsViewController.make()
  private let disposeBag = DisposeBag()

  deinit {
    Dispatcher.shared.unregister(store: self.store)
  }

}

// MARK: - Lifecycle
extension MenuEditViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    Dispatcher.shared.register(store: self.store)
    self.followingTagsVC.setEditing(true, animated: false)
    self.currentTagsVC.setEditing(true, animated: false)

    self.bind(store: self.store)
    self.actionCreator.sync(with: Authentication.isStored.asObservable(), and: MenuRecord.instance.tags)
  }
}

extension MenuEditViewController {
  func bind(store: MenuEditViewModel.MenuEditStore) {
    store.state.followingTagsState.asDriver().drive(onNext: { [weak self] state in
      guard let _self = self else { return }

      switch state {
      case .initial:
        break
      case .requesting:
        LoadingStateView.fill(in: _self.followingTagsContainer)
      case .authRequired:
        let authView = AuthRequiredView.loadFromNib()
        _self.followingTagsContainer.minq.fill(with: authView)
      case .empty:
        EmptyStateView.fill(in: _self.followingTagsContainer)
      case .failed:
        FailedStateView.fill(in: _self.followingTagsContainer)
      case .done(let tags):
        _self.followingTagsVC.tags = tags
        _self.followingTagsContainer.minq.fill(with: _self.followingTagsVC.view)
        _self.followingTagsVC.tableView.reloadData()
        _self.followingTagsHeight.constant = max(
          AppInfo.followingTagsMinimumHeight,
          CGFloat(tags.count * 44)
        )
      }
    }).disposed(by: self.disposeBag)

    store.state.currentTagsState.asDriver().drive(onNext: { [weak self] state in
      guard let _self = self else { return }

      switch state {
      case .initial:
        break
      case .initialized(let tags):
        _self.currentTagsContainer.minq.fill(with: _self.currentTagsVC.view)
        _self.currentTagsVC.minq.showContents()
        _self.currentTagsVC.tags = tags
        _self.currentTagsVC.tableView.reloadData()
        _self.currentTagsHeight.constant = max(AppInfo.currentTagsMinumumHeight, CGFloat(44 * tags.count))
      case .empty:
        EmptyStateView.fill(in: _self.currentTagsContainer, animation: true)
        _self.currentTagsHeight.constant = AppInfo.currentTagsMinumumHeight
      case .update(let changes):
        UIView.performWithoutAnimation {
          _self.currentTagsContainer.minq.fill(with: _self.currentTagsVC.view)
          _self.currentTagsVC.minq.showContents()
          _self.currentTagsHeight.constant = max(
            AppInfo.currentTagsMinumumHeight,
            CGFloat(44 * changes.tags.count)
          )
        }
        _self.currentTagsContainer.layoutIfNeeded()
        _self.currentTagsVC.apply(changes: changes)

      }
    }).disposed(by: self.disposeBag)
  }
}
