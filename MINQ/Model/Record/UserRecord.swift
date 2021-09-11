import RealmSwift
import Foundation

final class UserRecord: Object {
  @Persisted var id: String?
  @Persisted var name: String?
  @Persisted var profileImageUrl: String?

  let items = LinkingObjects(fromType: ItemRecord.self, property: "user")

  override static func primaryKey() -> String? {
    return "id"
  }
}

extension UserRecord {
  convenience init(entity: User) {
    self.init()
    self.id = entity.id
    self.name = entity.name
    self.profileImageUrl = entity.profileImageUrl
  }
}
