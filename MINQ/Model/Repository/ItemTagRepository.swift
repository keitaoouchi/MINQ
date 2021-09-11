import RxSwift

struct ItemTagRepository {
  static func findFollowedByMe(paging: Paging) -> Single<TagsContainer> {
    if AuthenticationRepository.find() != nil {
      return UserRepository.whoami().flatMap { userContainer in
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
          contents: container.contents,
          links: container.links,
          rateLimit: container.rateLimit
        )
      }
  }

  func isFollowing(_ itemTag: ItemTag) -> Single<Bool> {
    return API
      .provider
      .rx
      .request(.isFollowingTag(tag: itemTag))
      .map { response in
        return response.statusCode == 204
      }
  }
}
