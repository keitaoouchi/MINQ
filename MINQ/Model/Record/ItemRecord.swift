import RealmSwift
import Foundation

final class ItemRecord: Object {
  @Persisted var id: String?
  @Persisted var body: String?
  @Persisted var commentsCount: Int?
  @Persisted var createdAt: String?
  @Persisted var likesCount: Int?
  @Persisted var readAt: Date?
  @Persisted var title: String?
  @Persisted var updatedAt: String?
  @Persisted var url: String?
  @Persisted var user: UserRecord?
  @Persisted var tags: List<TagRecord>

  override static func primaryKey() -> String? {
    return "id"
  }
}

extension ItemRecord {
  convenience init(_ entity: Item) {
    self.init()
    self.id = entity.id
    self.body = entity.body
    self.commentsCount = entity.commentsCount
    self.createdAt = entity.createdAt
    self.likesCount = entity.likesCount
    self.title = entity.title
    self.updatedAt = entity.updatedAt
    self.url = entity.url

    self.user = UserRecord(entity: entity.user)
    self.tags.append(objectsIn: TagRecord.new(by: entity.tags))
  }

  static func new(by entities: [Item]?) -> List<ItemRecord> {
    let result = List<ItemRecord>()
    entities?.map { ItemRecord($0) }.forEach {
      result.append($0)
    }
    return result
  }
}
