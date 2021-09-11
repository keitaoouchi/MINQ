import Foundation
import Moya
import RxSwift

struct User: MINQCodable, Hashable {
  let id: String
  var name: String?
  var profileImageUrl: String?
}

// MARK: - Init
extension User {
  init?(record: UserRecord?) {
    guard let record = record else { return nil }
    guard
      let id = record.id else {
        return nil
    }

    self.init(
      id: id,
      name: record.name,
      profileImageUrl: record.profileImageUrl
    )
  }

  init(id: String) {
    self.init(id: id,
              name: nil,
              profileImageUrl: nil
    )
  }
}
