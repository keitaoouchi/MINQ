import Moya
import UIKit

enum APIError: Error {
  case mappingError
  case responseError
  case notAuthorized
}

enum AuthRequiredType {
  case required
  case optional
  case none
}

enum API: TargetType {
  case signin(id: String, secret: String, code: String)
  case signout(accessToken: String)

  case item(id: String)
  case tagItems(tag: ItemTag, paging: Paging)
  case userItems(user: User, paging: Paging)
  case userStockedItems(user: User, paging: Paging)
  case anyItems(query: String, paging: Paging)
  case comments(id: String)

  case isFollowingTag(tag: ItemTag)
  case followTag(tag: ItemTag)
  case unfollowTag(tag: ItemTag)
  case followingTags(user: User, paging: Paging)

  case isLikedItem(item: Item)
  case likeItem(item: Item)
  case unlikeItem(item: Item)

  case isStockedItem(item: Item)
  case stockItem(item: Item)
  case unstockItem(item: Item)

  case user(id: String)
  case authenticatedUser
}

extension API {
  static private(set) var provider: MoyaProvider<API> = defaultProvider

  static private var defaultProvider: MoyaProvider<API> {
    return MoyaProvider<API>(
      plugins: [NetworkLoggingPlugin(), AuthenticationPlugin()]
    )
  }

  static func resetProvider() {
    API.provider = defaultProvider
  }

  static func stub(provider: MoyaProvider<API>) {
    API.provider = provider
  }
}

extension API {

  var baseURL: URL {
    return URL(string: "https://qiita.com/api/v2")!
  }

  var path: String {
    switch self {
    case .signin:
      return "/access_tokens"
    case .signout(let accessToken):
      return "/access_tokens/\(accessToken)"
    case .item(let id):
      return "/items/\(id)"
    case .tagItems(let tag, _):
      return "/tags/\(tag.name)/items"
    case .userItems(let user, _):
      return "/users/\(user.id)/items"
    case .userStockedItems(let user, _):
      return "/users/\(user.id)/stocks"
    case .anyItems:
      return "/items"
    case .comments(let id):
      return "/items/\(id)/comments"
    case .isFollowingTag(let tag),
         .followTag(let tag),
         .unfollowTag(let tag):
      return "/tags/\(tag.name)/following"
    case .followingTags(let user, _):
      return "/users/\(user.id)/following_tags"
    case .isLikedItem(let item),
         .likeItem(let item),
         .unlikeItem(let item):
      return "/items/\(item.id)/like"
    case .isStockedItem(let item),
         .stockItem(let item),
         .unstockItem(let item):
      return "/items/\(item.id)/stock"
    case .user(let id):
      return "/users/\(id)"
    case .authenticatedUser:
      return "/authenticated_user"
    }
  }

  var method: Moya.Method {
    switch self {
    case .signin:
      return .post
    case .signout,
         .unfollowTag,
         .unlikeItem,
         .unstockItem:
      return .delete
    case .followTag,
         .likeItem,
         .stockItem:
      return .put
    default:
      return .get
    }
  }

  var task: Moya.Task {
    switch self {
    case .signin(let id, let secret, let code):
      return .requestParameters(
        parameters: ["client_id": id, "client_secret": secret, "code": code],
        encoding: JSONEncoding.default
      )
    case .tagItems(_, let paging),
         .userItems(_, let paging),
         .userStockedItems(_, let paging):
      return .requestParameters(
        parameters: ["page": paging.page, "per_page": paging.perPage],
        encoding: URLEncoding.queryString
      )
    case .anyItems(let query, let paging):
      return .requestParameters(
        parameters: ["query": query, "page": paging.page, "per_page": paging.perPage],
        encoding: URLEncoding.queryString
      )
    default:
      return .requestPlain
    }
  }

  var headers: [String: String]? {
    switch self.authRequired {
    case .none:
      return nil
    default:
      if let authentication = AuthenticationRepository.find() {
        return ["Authorization": "Bearer \(authentication.accessToken)"]
      } else {
        return nil
      }
    }
  }

  var sampleData: Data {
    return Data()
  }
}

extension API {
  var authRequired: AuthRequiredType {
    switch self {
    case .signin:
      return .none
    case .tagItems, .userItems, .userStockedItems, .anyItems:
      return .optional
    default:
      return .required
    }
  }
}
