import UIKit
import RxSwift
import RxRelay
import RealmSwift
import FluxxKit

final class HistoryViewController: UITableViewController {
  private let items: BehaviorRelay<[Item]>
  private let notificationToken: NotificationToken
  private let disposeBag = DisposeBag()

  init() {
    let watcher = ItemRepository.watchReadItems()
    items = watcher.items
    notificationToken = watcher.token
    super.init(style: .grouped)
    tableView.separatorStyle = .none
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    notificationToken.invalidate()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.backgroundColor = Asset.Colors.bg.color
    tableView.separatorInset = Style.Margin.itemCollection

    tableView.register(cellType: HistoryCell.self)

    items.subscribe { [weak self] event in
      switch event {
      case .next:
        self?.tableView.reloadData()
      default:
        break
      }
    }.disposed(by: disposeBag)
  }
}

extension HistoryViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIView(frame: .zero)
    let label = UILabel()
    label.text = L10n.viewHistory
    label.font = Style.Font.base(20, .bold)
    let margin = Style.Margin.itemCollection
    view.minq.attach(label, top: margin.top, leading: margin.left, trailing: nil, bottom: -8)
    return view
  }

  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    return nil
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.value.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let item = items.value[indexPath.row]
    let cell = tableView.dequeueReusableCell(for: indexPath) as HistoryCell
    let showSeparator = tableView.numberOfRows(inSection: 0) != indexPath.row + 1
    cell.apply(item: item, showSeparator: showSeparator) { user in
      Dispatcher.shared.dispatch(action: Navigator.Link.user(user))
    }
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items.value[indexPath.row]
    Dispatcher.shared.dispatch(
      action: Navigator.Link.item(item))
  }

  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    .leastNormalMagnitude
  }
}
