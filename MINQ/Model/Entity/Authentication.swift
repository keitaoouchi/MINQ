import Moya
import RxSwift
import KeychainAccess
import Result

/// 認証情報
struct Authentication: MINQCodable {
  let accessToken: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "token"
  }
}

extension Authentication {

  static var isStored: Variable<Bool> = {
    let initialValue = (Authentication.retrieve() != nil)
    return Variable<Bool>(initialValue)
  }()
}

// MARK: - CRUD
extension Authentication {

  static func retrieve() -> Authentication? {
    return AuthenticationStore.retrieve()
  }

  static func destroy() -> Single<Bool> {
    guard let authentication = Authentication.retrieve() else {
      return Single.just(true)
    }

    return API
      .provider
      .rx
      .request(.signout(accessToken: authentication.accessToken))
      .map { response in
        return response.statusCode == 204
      }
      .do(
        onSuccess: { _ in
          AuthenticationStore.clear()
        },
        onError: { _ in
          AuthenticationStore.clear()
        }
      )
  }

  static func clear() {
    AuthenticationStore.clear()
  }

  func save() {
    AuthenticationStore.store(authentication: self)
  }

}

// MARK: - API
extension Authentication {

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
          authentication.save()
        },
        onError: { error in
          Debugger.shared.error("[MINQ][AUTHENTICATION_ERROR] \(error)")
        }
      )
  }
}

// MARK: - <Private>認証情報の永続化層
private struct AuthenticationStore {

  static func clear() {
    do {
      try keychain.remove("access_token")
      Authentication.isStored.value = false
    } catch {
      Debugger.shared.error("[MINQ][AUTHENTICATION_ERROR] \(error)")
    }
  }

  static func store(authentication: Authentication) {
    keychain["access_token"] = authentication.accessToken
    Authentication.isStored.value = true
  }

  /// Keychainから永続化されたデータを読み取りAuthenticationインスタンスを生成できれば返す
  static func retrieve() -> Authentication? {
    let keychain = AuthenticationStore.keychain
    let accessToken = keychain["access_token"]

    if let accessToken = accessToken {
      return Authentication(accessToken: accessToken)
    }
    return nil
  }

  static var keychain: Keychain = {
    let keychain = Keychain(service: "cptechtask")
      .synchronizable(false)
      .accessibility(Accessibility.afterFirstUnlockThisDeviceOnly)
    return keychain
  }()

}
