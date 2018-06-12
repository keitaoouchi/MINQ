import Foundation
import Moya
import RxSwift
import RealmSwift

struct FollowingTag: MINQCodable {
  let id: String

  var asTag: Tag {
    return Tag(name: id)
  }
}

struct Tag: MINQCodable {
  let name: String
}

extension Tag {

  init?(record: TagRecord) {
    guard let name = record.name else {
      return nil
    }
    self.init(name: name)
  }

  static func from(records: List<TagRecord>) -> [Tag] {
    return records.compactMap { Tag(record: $0) }
  }
}

// MARK: - API
extension Tag {

  static func findFollowedByMe(paging: Paging) -> Single<TagsContainer> {
    if Authentication.retrieve() != nil {
      return User.whoami().flatMap { userContainer in
        return findFollowed(by: userContainer.content,
                            paging: paging)
      }
    } else {
      return Single.error(AuthError.notAuthorized)
    }
  }

  static func findFollowed(by user: User, paging: Paging) -> Single<TagsContainer> {
    return API
      .provider
      .rx
      .request(.followingTags(user: user, paging: paging))
      .map { response -> ContentsContainer<FollowingTag> in
        if let container = ContentsContainer<FollowingTag>.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
      }.map { container in
        return TagsContainer(
          contents: container.contents.map { $0.asTag },
          links: container.links,
          rateLimit: container.rateLimit
        )
      }
  }

  func isFollowing() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.isFollowingTag(tag: self))
      .map { response in
        return response.statusCode == 204
      }
  }

  func follow() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.followTag(tag: self))
      .map { response in
        return response.statusCode == 204
      }
  }

  func unfollow() -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.unfollowTag(tag: self))
      .map { response in
        return response.statusCode == 204
      }
  }
}
