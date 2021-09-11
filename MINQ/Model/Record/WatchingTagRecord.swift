import RealmSwift

final class WatchingTagRecord: Object {
  @Persisted var id: String?
  @Persisted var order: Int?
  override static func primaryKey() -> String? {
    return "id"
  }
}
