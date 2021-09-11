import RealmSwift

final class FollowingTagRecord: Object {
  @Persisted var id: String?
  @Persisted var isWatching: Bool = false
  override static func primaryKey() -> String? {
    return "id"
  }

  convenience init(tag: FollowingTag) {
    self.init()
    self.id = tag.id
    self.isWatching = WatchingTagRepository.contains(named: tag.id)
  }
}
