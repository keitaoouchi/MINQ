import RealmSwift

extension TagRecord {
  convenience init(entity: Tag) {
    self.init()
    self.name = entity.name
  }

  static func new(by entities: [Tag]?) -> List<TagRecord> {
    let result = List<TagRecord>()
    entities?.map { TagRecord(entity: $0) }.forEach {
      result.append($0)
    }
    return result
  }
}
