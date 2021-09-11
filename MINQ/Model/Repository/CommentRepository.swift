import RxSwift
import Moya

struct CommentRepository {
  static func find(of item: Item) -> Single<[Comment]> {
    return API
      .provider
      .rx
      .request(.comments(id: item.id))
      .mapComments()
  }
}

fileprivate extension PrimitiveSequenceType where Trait == SingleTrait, Element == Response {
  func mapComments() -> Single<[Comment]> {
    self.map { response in
      if response.statusCode != 200 {
        throw APIError.responseError
      } else if let comments: [Comment] = Comment.from(data: response.data) {
        return comments
      } else {
        throw APIError.mappingError
      }
    }
  }
}
