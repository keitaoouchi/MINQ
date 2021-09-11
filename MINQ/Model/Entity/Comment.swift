import Foundation

struct Comment: MINQCodable, Hashable {
  let id: String
  let body: String
  let createdAt: String
  let updatedAt: String
  let user: User
}
