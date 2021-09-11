import Foundation

struct FollowingTag: MINQCodable, Hashable {
  let id: String
  let isWatching: Bool

  enum CodingKeys: String, CodingKey {
    case id
  }

  init(id: String, isWatching: Bool) {
    self.id = id
    self.isWatching = isWatching
  }

  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    id = try values.decode(String.self, forKey: .id)
    isWatching = WatchingTagRepository.contains(named: id)
  }
}
