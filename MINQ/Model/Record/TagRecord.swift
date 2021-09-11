import RealmSwift
import Foundation

final class TagRecord: Object {
  @Persisted var name: String?

  let items = LinkingObjects(fromType: ItemRecord.self, property: "tags")

  override static func primaryKey() -> String? {
    return "name"
  }
}

extension TagRecord {
  convenience init(entity: ItemTag) {
    self.init()
    self.name = entity.name
  }

  static func new(by entities: [ItemTag]?) -> List<TagRecord> {
    let result = List<TagRecord>()
    entities?.map { TagRecord(entity: $0) }.forEach {
      result.append($0)
    }
    return result
  }
}
