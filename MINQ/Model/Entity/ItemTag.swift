import Foundation
import Moya
import RxSwift
import RealmSwift

struct ItemTag: MINQCodable, Hashable {
  let name: String
}

extension ItemTag {
  init?(record: TagRecord) {
    guard let name = record.name else {
      return nil
    }
    self.init(name: name)
  }

  static func from(records: List<TagRecord>) -> [ItemTag] {
    return records.compactMap { ItemTag(record: $0) }
  }
}
