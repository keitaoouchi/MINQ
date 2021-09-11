import Foundation
import Moya

final class NetworkLoggingPlugin: PluginType {

  func willSend(_ request: RequestType, target: TargetType) {
    let method = target.method.rawValue.uppercased()
    Debugger.shared.verbose("[NETWORK][REQUEST] \(method) \(target.path)")
  }

  func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
    switch result {
    case .success(let response):
      let statusCode = response.statusCode
      if statusCode < 400 {
        Debugger.shared.verbose("[NETWORK][SUCCESS] <\(statusCode)> @ \(target.path)")
      } else {
        Debugger.shared.verbose("[NETWORK][ERROR] <\(statusCode)> @ \(target.path)")
      }
    case .failure(let error):
      Debugger.shared.error("[NETWORK][ERROR] \(error) @ \(target.path)")
    }
  }

}
