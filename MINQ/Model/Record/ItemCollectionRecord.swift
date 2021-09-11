import Foundation
import RealmSwift

/// ItemQuery.QueryTypeとItemRecordを紐付けるブリッジテーブル
final class ItemCollectionRecord: Object {

  let items = List<ItemRecord>()
  @objc private dynamic var typeString: String?
  /// APIレスポンスのページングデータを格納
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

  var paging: Paging {
    Paging(page: items.count / Constant.perPage, perPage: Constant.perPage)
  }

  // updatedAtが24時間以内
  var isOutdated: Bool {
    guard !items.isEmpty else { return true }
    guard let updatedAt = updatedAt else { return true }

    return updatedAt.addingTimeInterval(Constant.outdatedLimit) < Date()
  }

  var containered: ItemsContainer {
    ItemsContainer(contents: items.compactMap { Item(record: $0) }, links: [], rateLimit: nil)
  }
}
