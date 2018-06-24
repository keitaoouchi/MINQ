import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import FluxxKit

final class SettingsViewController: UITableViewController {

  @IBOutlet weak var signoutCell: UITableViewCell!
  @IBOutlet weak var userContainerView: UIView!

  private let store = SettingsViewModel.make()
  private lazy var actionCreator: SettingsViewModel.ActionCreator = {
    return SettingsViewModel.ActionCreator(store: self.store)
  }()
  private let disposeBag = DisposeBag()

  deinit {
    Dispatcher.shared.unregister(store: self.store)
  }

  override func loadView() {
    super.loadView()
    self.minq.setTabBarItem(image: AppInfo.settingsImage, title: "設定")
    self.navigationItem.titleView = UIImageView(
      image: Asset.Images.logoDeepGreen.image
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    Dispatcher.shared.register(store: self.store)

    self
      .store
      .state
      .viewState
      .asDriver()
      .drive(onNext: { [weak self] state in
        switch state {
        case .initial:
          break
        case .requesting:
          let loadingView = LoadingStateView.loadFromNib()
          loadingView.backgroundColor = .clear
          self?.userContainerView.minq.fill(with: loadingView)
        case .anonymouse:
          let noneView = NonSignedinView(frame: .zero)
          noneView.onSignin = {
            Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
          }
          self?.userContainerView.minq.fill(with: noneView)
        case .signed(let user):
          let userView = SignedinUserView(frame: .zero)
          userView.apply(user: user)
          self?.userContainerView.minq.fill(with: userView)
        case .failed:
          break
        }
      }).disposed(by: self.disposeBag)

    self.actionCreator.sync(with: Authentication.isStored)
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let section = indexPath.section
    let row = indexPath.row
    if section == 0 {
      if row == 0 {
        if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      }
    } else {
      if row == 0 {
        self.actionCreator.clearCache()
      } else {
        self.actionCreator.signout()
      }
    }
    tableView.deselectRow(at: indexPath, animated: true)

  }

}
