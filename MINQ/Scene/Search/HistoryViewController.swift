import UIKit
import RealmSwift
import FluxxKit

final class HistoryViewController: UITableViewController {
  var records: Results<ItemRecord> = try! ItemRecord.findReadItems()
  var notification: NotificationToken?

  static func make() -> HistoryViewController {
    return StoryboardScene.Search.history.instantiate()
  }

  deinit {
    self.notification?.invalidate()
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.notification = self.records.observe { [weak self] _ in
      self?.tableView.reloadData()
    }
  }
}

extension HistoryViewController {

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return records.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let record = records[indexPath.row]
    let cell = tableView.dequeueReusableCell(for: indexPath) as HistoryCell
    cell.apply(record: record)
    return cell
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let record = records[indexPath.row]
    Dispatcher.shared.dispatch(
      action: Navigator.Link.item(item: record))
  }

}
