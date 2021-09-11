import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import FluxxKit

final class SettingsViewController: UITableViewController {
  private let userContainerView: UIView = {
    let view = UIView(frame: .zero)
    view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    return view
  }()

  private let store = SettingsViewModel.make()
  private lazy var actionCreator: SettingsViewModel.ActionCreator = {
    return SettingsViewModel.ActionCreator(store: self.store)
  }()
  private let disposeBag = DisposeBag()

  init() {
    super.init(style: .insetGrouped)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    Dispatcher.shared.unregister(store: self.store)
  }
}

// MARK: - lifecycle
extension SettingsViewController {
  override func loadView() {
    super.loadView()
    minq.setTabBarItem(image: Icon.settingsImage, title: L10n.setting)
    navigationItem.titleView = UIImageView(
      image: Asset.Images.logo.image
    )
    tableView.backgroundColor = Asset.Colors.bg.color
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.isTranslucent = false

    Dispatcher.shared.register(store: store)

    bind()

    actionCreator.sync(with: AuthenticationRepository.storing)
  }
}

// MARK: - biding
extension SettingsViewController {
  func bind() {
    store
      .state
      .viewState
      .asDriver()
      .drive(onNext: { [weak self] state in
        switch state {
        case .initial:
          break
        case .requesting:
          let loadingView = LoadingStateView(style: .medium)
          self?.userContainerView.minq.fill(with: loadingView, clean: true)
        case .anonymouse:
          self?.userContainerView.minq.removeComplementalStateView()
          let noneView = NonSignedinView {
            Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
          }
          self?.userContainerView.minq.fill(with: noneView, clean: true)
        case .signed(let user):
          self?.userContainerView.minq.removeComplementalStateView()
          let userView = SignedinUserView(user: user)
          self?.userContainerView.minq.fill(with: userView, clean: true)
        case .failed:
          break
        }
        self?.tableView.reloadData()
      }).disposed(by: disposeBag)
  }
}

// MARK: - uitableview
extension SettingsViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return userContainerView
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    AuthenticationRepository.isStoring ? 3 : 2
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .default, reuseIdentifier: "\(indexPath.row)")
    if let row = Row(rawValue: indexPath.row) {
      var content = cell.defaultContentConfiguration()
      content.text = row.title
      content.textProperties.color = row.titleColor
      cell.accessoryType = row.accessory
      cell.contentConfiguration = content
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch Row(rawValue: indexPath.row) {
    case .settings:
      if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    case .clearCache:
      actionCreator.clearCache()
    case .logout:
      actionCreator.signout()
    case .none:
      break
    }
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

private enum Row: Int {
  case settings = 0
  case clearCache
  case logout

  var title: String {
    switch self {
    case .settings:
      return L10n.openSettings
    case .clearCache:
      return L10n.clearCache
    case .logout:
      return L10n.logout
    }
  }

  var titleColor: UIColor {
    switch self {
    case .settings:
      return .label
    case .clearCache:
      return Asset.Colors.blue.color
    case .logout:
      return Asset.Colors.red.color
    }
  }

  var accessory: UITableViewCell.AccessoryType {
    switch self {
    case .settings: return .disclosureIndicator
    default: return .none
    }
  }
}
