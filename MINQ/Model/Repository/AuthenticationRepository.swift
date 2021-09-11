import RxRelay
import RxSwift
import KeychainAccess

struct AuthenticationRepository {
  static var isStoring: Bool { storing.value }
  static var storing: BehaviorRelay<Bool> = {
    let initialValue = (find() != nil)
    return BehaviorRelay<Bool>(value: initialValue)
  }()
}

// MARK: - CRUD
extension AuthenticationRepository {
  static func find() -> Authentication? {
    let accessToken = keychain["access_token"]

    if let accessToken = accessToken {
      return Authentication(accessToken: accessToken)
    }
    return nil
  }

  static func destroy() -> Single<Bool> {
    clear()
    guard let authentication = find() else {
      return Single.just(true)
    }

    return API
      .provider
      .rx
      .request(.signout(accessToken: authentication.accessToken))
      .map { response in
        return response.statusCode == 204
      }
  }

  static func save(_ authentication: Authentication) {
    keychain["access_token"] = authentication.accessToken
    Self.storing.accept(true)
  }
}

// MARK: - API
extension AuthenticationRepository {

  /// 認証API仕様
  /// - Note: https://unsplash.com/documentation#user-authentication
  /// - Note: 認証の前段部はSigninViewControllerのSFAuthenticationSession
  static func apply(code: String) -> Single<Authentication> {
    return API
      .provider
      .rx
      .request(.signin(id: OAuthService.clientId,
                       secret: OAuthService.clientSecret,
                       code: code))
      .map { response -> Authentication in
        if let authentication: Authentication = Authentication.from(data: response.data) {
          return authentication
        } else {
          throw APIError.mappingError
        }
      }.do(
        onSuccess: { authentication in
          save(authentication)
        },
        onError: { error in
          Debugger.shared.error("[MINQ][AUTHENTICATION_ERROR] \(error)")
        }
      )
  }
}

// MARK: - MISC
private extension AuthenticationRepository {
  static func clear() {
    do {
      try keychain.remove("access_token")
      Self.storing.accept(false)
    } catch {
      Debugger.shared.error("[MINQ][AUTHENTICATION_ERROR] \(error)")
    }
  }

  static var keychain: Keychain = {
    let keychain = Keychain(service: "cptechtask")
      .synchronizable(false)
      .accessibility(Accessibility.afterFirstUnlockThisDeviceOnly)
    return keychain
  }()
}
