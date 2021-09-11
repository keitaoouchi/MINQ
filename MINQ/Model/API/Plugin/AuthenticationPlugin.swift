import Foundation
import Moya
import RxSwift
import FluxxKit

final class AuthenticationPlugin: PluginType {

  typealias OnComplete = MoyaProvider<API>.RequestResultClosure

  private let requestQueue = DispatchQueue(label: "com.keita.oouchi.MINQ")
  private let disposeBag = DisposeBag()

  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case .success(let response):
      if response.statusCode == 401 {
        Debugger.shared.error("[MINQ][AUTH_PLUGIN][ERROR_RESPONSE] \(response)")
        self.handleInvalidAuthentication(response: response)
      }
    case .failure(let error):
      Debugger.shared.error("[MINQ][AUTH_PLUGIN][ERROR] \(error)")
      if error.response?.statusCode == 401 {
        self.handleInvalidAuthentication(response: error.response)
      }
    }
  }
}

// MARK: - private
private extension AuthenticationPlugin {

  func authorize(request: inout URLRequest, with authentication: Authentication) {
    request.addValue("Bearer \(authentication.accessToken)", forHTTPHeaderField: "Authorization")
  }

  func handleInvalidAuthentication(response: Response? = nil) {
    if let response = response,
      let error: ErrorMessage = ErrorMessage.from(data: response.data), error.isUnauthorized {
      Debugger.shared.error("[MINQ][API][UNAUTHORIZED]")
    }
  }

}
