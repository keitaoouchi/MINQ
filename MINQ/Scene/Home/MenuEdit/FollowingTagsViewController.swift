import UIKit
import RealmSwift
import FluxxKit

final class FollowingTagsViewController: UITableViewController {

  var tags: [Tag]!
  private let currentTags = MenuRecord.instance.tags
  private var notificationToken: NotificationToken?

  deinit {
    notificationToken?.invalidate()
  }

  static func make(tags: [Tag] = []) -> FollowingTagsViewController {
    let vc = StoryboardScene.MenuEdit.followingTags.instantiate()
    vc.tags = tags
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(cellType: TagCell.self)

    self.notificationToken = MenuRecord.instance.observe { [weak self] _ in
      self?.tableView.reloadData()
    }
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let tag = tags[indexPath.row]
    let cell = tableView.dequeueReusableCell(for: indexPath) as TagCell
    cell.apply(tag: tag)
    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    let tag = tags[indexPath.row]
    try? MenuRecord.instance.append(tag: tag)
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    let tag = tags[indexPath.row]
    if currentTags.contains(where: { $0.name == tag.name }) {
      return .none
    }
    return .insert
  }
}
