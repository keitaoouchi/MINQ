import UIKit
import RealmSwift

final class CurrentTagsViewController: UITableViewController {

  var tags: [Tag] = []

  static func make() -> CurrentTagsViewController {
    let vc = StoryboardScene.MenuEdit.currentTags.instantiate()
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(cellType: TagCell.self)
  }

  func apply(changes: MenuEditViewModel.CurrentTagsChanges) {
    self.tags = changes.tags
    guard changes.isNotComplicatedOperation else {
      self.tableView.reloadData()
      return
    }

    self.tableView.beginUpdates()
    self.tableView.reloadRows(at: changes.modifications, with: .automatic)
    self.tableView.deleteRows(at: changes.deletions, with: .automatic)
    self.tableView.insertRows(at: changes.insertions, with: .automatic)
    self.tableView.endUpdates()
  }

  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tags.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(for: indexPath) as TagCell
    let tag = tags[indexPath.row]
    cell.apply(tag: tag)
    return cell
  }

  override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
    return .delete
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    try? MenuRecord.instance.remove(named: tags[indexPath.row].name)
  }

  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    return true
  }

  override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let tagName = tags[sourceIndexPath.row].name
    try? MenuRecord.instance.move(named: tagName, to: destinationIndexPath.row)
  }
}
