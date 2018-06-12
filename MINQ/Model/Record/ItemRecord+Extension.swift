import RealmSwift
import Foundation

extension ItemRecord {

  convenience init(entity: Item) {
    self.init()
    self.id = entity.id
    self.body = entity.body
    self.commentsCount.value = entity.commentsCount
    self.createdAt = entity.createdAt
    self.isPrivate.value = entity.isPrivate
    self.likesCount.value = entity.likesCount
    self.title = entity.title
    self.updatedAt = entity.updatedAt
    self.url = entity.url

    self.user = UserRecord(entity: entity.user)
    self.tags.append(objectsIn: TagRecord.new(by: entity.tags))
  }

  static func new(by entities: [Item]?) -> List<ItemRecord> {
    let result = List<ItemRecord>()
    entities?.map { ItemRecord(entity: $0) }.forEach {
      result.append($0)
    }
    return result
  }
}

// MARK: - CRUD
extension ItemRecord {

  static func find(by id: String) throws -> ItemRecord? {
    let realm = try Realm()
    if let record = realm.object(ofType: ItemRecord.self,
                                 forPrimaryKey: id) {
      return record
    } else {
      return nil
    }
  }

  static func findReadItems() throws -> Results<ItemRecord> {
    let realm = try Realm()
    return realm.objects(ItemRecord.self).filter("readAt != nil").sorted(byKeyPath: "readAt", ascending: false)
  }

  static func save(entity: Item) throws {
    let realm = try Realm()
    try realm.write {
      let record = ItemRecord(entity: entity)
      realm.add(record, update: true)
    }
  }

  func touch() throws {
    let realm = try Realm()
    try realm.write {
      self.readAt = Date()
      realm.add(self, update: true)
    }
  }
}
