import RealmSwift
import Foundation
import RxSwift

final class MenuRecord: Object {

  var tags = List<TagRecord>()

  static var instance: MenuRecord {
    try! storeInitialRecordsIfNeeded()

    let realm = try! Realm()
    return realm.objects(MenuRecord.self).first!
  }

  func contains(tag: Tag) -> Bool {
    return tags.contains { $0.name == tag.name }
  }

  func append(tag: Tag) throws {
    guard !self.contains(tag: tag) else { return }

    let realm = try Realm()
    try realm.write {
      let tagRecord = TagRecord(entity: tag)
      realm.add(tagRecord, update: true)
      self.tags.append(tagRecord)
    }
  }

  func remove(named tagName: String) throws {
    let realm = try Realm()
    try realm.write {
      if let index = self.tags.index(matching: "name = %@", tagName) {
        self.tags.remove(at: index)
      }
    }
  }

  func move(named tagName: String, to index: Int) throws {
    let realm = try Realm()
    try realm.write {
      if let originalIndex = self.tags.index(matching: "name = %@", tagName), index != originalIndex {
        self.tags.move(from: originalIndex, to: index)
      }
    }
  }

  private static func storeInitialRecordsIfNeeded() throws {
    let realm = try Realm()
    guard realm.objects(MenuRecord.self).isEmpty else { return }

    try realm.write {
      let record = MenuRecord()

      let defaultTags = [
        TagRecord(entity: Tag(name: "Swift")),
        TagRecord(entity: Tag(name: "JavaScript")),
        TagRecord(entity: Tag(name: "AWS")),
        TagRecord(entity: Tag(name: "機械学習"))
      ]
      defaultTags.forEach { tag in
        realm.add(tag, update: true)
      }
      record.tags.append(objectsIn: defaultTags)
      realm.add(record)
    }
  }
}
