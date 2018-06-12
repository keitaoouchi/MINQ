import Foundation
import RealmSwift

/// ItemQuery.QueryTypeとItemRecordを紐付けるブリッジテーブル
final class ItemCollectionRecord: Object {

  let items = List<ItemRecord>()
  @objc private dynamic var typeString: String?
  /// APIレスポンスのページングデータを格納
  @objc dynamic var pagingData: Data?
  @objc dynamic var updatedAt: Date?

  override static func primaryKey() -> String? {
    return "typeString"
  }
}

extension ItemCollectionRecord {

  var type: ItemQuery.QueryType? {
    get {
      guard let typeString = typeString else { return nil }

      return ItemQuery.QueryType.make(from: typeString)
    }
    set {
      self.typeString = newValue?.tableKey
    }
  }

  var paging: Paging? {
    guard let data = pagingData else { return nil }
    return Paging.from(data: data)
  }

  // updatedAtが24時間以内
  var isOutdated: Bool {
    guard !items.isEmpty else { return true }
    guard let updatedAt = updatedAt else { return true }

    return updatedAt.addingTimeInterval(AppInfo.outdatedLimit) < Date()
  }
}

// MARK: - CRUD
extension ItemCollectionRecord {

  static func find(of type: ItemQuery.QueryType) throws -> ItemCollectionRecord? {
    let realm = try Realm()
    if let record = realm.object(ofType: ItemCollectionRecord.self,
                                 forPrimaryKey: type.tableKey) {
      return record
    } else {
      return nil
    }
  }

  static func findOrNew(of type: ItemQuery.QueryType) throws -> ItemCollectionRecord {
    let realm = try Realm()
    if let record = realm.object(ofType: ItemCollectionRecord.self,
                                 forPrimaryKey: type.tableKey) {
      return record
    } else {
      let record = ItemCollectionRecord()
      record.type = type
      return record
    }
  }

  static func findOrCreate(of type: ItemQuery.QueryType) throws -> ItemCollectionRecord {
    let realm = try Realm()
    if let record = realm.object(ofType: ItemCollectionRecord.self,
                                 forPrimaryKey: type.tableKey) {
      return record
    } else {
      let record = ItemCollectionRecord()
      try realm.write {
        record.type = type
        realm.add(record)
      }
      return record
    }
  }

  static func save(of type: ItemQuery.QueryType,
                   with items: [Item],
                   paging: Paging?) throws {
    let realm = try Realm()
    try realm.write {
      let itemRecords = ItemRecord.new(by: items)
      let record = try ItemCollectionRecord.findOrNew(of: type)
      record.items.removeAll()
      realm.add(itemRecords, update: true)
      record.items.append(objectsIn: itemRecords)
      record.updatedAt = Date()
      record.pagingData = paging?.jsonData
      realm.add(record, update: true)
    }
  }

  // 追加の場合はupdatedAtを更新しない
  static func append(of type: ItemQuery.QueryType,
                     with items: [Item],
                     paging: Paging?) throws {
    let realm = try Realm()
    try realm.write {

      let record = try ItemCollectionRecord.findOrNew(of: type)
      // 重複レコードのidを抽出する
      let duplicateIds = record
        .items
        .filter("id IN %@", items.map { $0.id }.sorted())
        .map { $0.id }
      let uniqueItems = items.filter { !duplicateIds.contains($0.id) }
      let itemRecords = ItemRecord.new(by: uniqueItems)
      realm.add(itemRecords, update: true)

      record.items.append(objectsIn: itemRecords)
      record.pagingData = paging?.jsonData
      realm.add(record, update: true)
    }
  }

}
