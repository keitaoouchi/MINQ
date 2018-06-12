import Foundation
import Moya
import RxSwift

struct User: MINQCodable {
  let id: String
  var name: String?
  var profile: String?
  var facebookId: String?
  var followeesCount: Int64?
  var followersCount: Int64?
  var githubLoginName: String?
  var itemsCount: Int64?
  var linkedinId: String?
  var location: String?
  var organization: String?
  var profileImageUrl: String?
  var twitterScreenName: String?
  var websiteUrl: String?
}

extension User {
  enum CodingKeys: String, CodingKey {
    case id
    case name
    case profile = "description"
    case facebookId = "facebook_id"
    case followeesCount = "followees_count"
    case followersCount = "followers_count"
    case githubLoginName = "github_login_name"
    case itemsCount = "items_count"
    case linkedinId = "linkedin_id"
    case location
    case organization
    case profileImageUrl = "profile_image_url"
    case twitterScreenName = "twitter_screen_name"
    case websiteUrl = "website_url"
  }
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
      profile: record.profile,
      facebookId: record.facebookId,
      followeesCount: record.followeesCount.value,
      followersCount: record.followersCount.value,
      githubLoginName: record.githubLoginName,
      itemsCount: record.itemsCount.value,
      linkedinId: record.linkedinId,
      location: record.location,
      organization: record.organization,
      profileImageUrl: record.profileImageUrl,
      twitterScreenName: record.twitterScreenName,
      websiteUrl: record.wesiteUrl
    )
  }

  init(id: String) {
    self.init(id: id,
              name: nil,
              profile: nil,
              facebookId: nil,
              followeesCount: nil,
              followersCount: nil,
              githubLoginName: nil,
              itemsCount: nil,
              linkedinId: nil,
              location: nil,
              organization: nil,
              profileImageUrl: nil,
              twitterScreenName: nil,
              websiteUrl: nil
    )
  }
}

// MARK: - API
extension User {

  static private var _user: UserContainer?

  static func whoami(force: Bool = true) -> Single<UserContainer> {
    if let userContainer = _user, !force {
      return Single.just(userContainer)
    }

    return API
      .provider
      .rx
      .request(.authenticatedUser)
      .map { response -> UserContainer in
        if let container = UserContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
      }.do(onSuccess: { userContainer in
        _user = userContainer
      })
  }

  static func find(by id: String) -> Single<UserContainer> {
    return API
      .provider
      .rx
      .request(.user(id: id))
      .map { response in
        if let container = UserContainer.from(response: response) {
          return container
        } else {
          throw APIError.mappingError
        }
      }
  }
}
