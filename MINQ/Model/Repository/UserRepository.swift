import RxSwift
// TODO: Authenticationと同じライフサイクルになるようにする
struct UserRepository {
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

  static func clearMe() {
    _user = nil
  }
}
