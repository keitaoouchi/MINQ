import RealmSwift

struct FollowingTagRepository {
  static func all() -> Results<FollowingTagRecord> {
    let realm = try! Realm()
    return realm.objects(FollowingTagRecord.self)
  }

  static func save(tags: [FollowingTag]) throws {
    let realm = try Realm()
    try realm.write {
      let records = tags.map { FollowingTagRecord(tag: $0) }
      let existingRecords = realm.objects(FollowingTagRecord.self)
      realm.delete(existingRecords)
      realm.add(records)
    }
  }

  static func watch(_ tag: FollowingTag) {
    let realm = try! Realm()
    try! realm.write {
      if let record = realm.object(ofType: FollowingTagRecord.self, forPrimaryKey: tag.id) {
        record.isWatching = true
        realm.add(record, update: .modified)
      }
      try! WatchingTagRepository.append(tag: ItemTag(name: tag.id), in: realm)
    }
  }

  static func unwatch(_ tag: FollowingTag) {
    let realm = try! Realm()
    try! realm.write {
      if let record = realm.object(ofType: FollowingTagRecord.self, forPrimaryKey: tag.id) {
        record.isWatching = false
        realm.add(record, update: .modified)
      }
      try! WatchingTagRepository.remove(named: tag.id, in: realm)
    }
  }
}
