import UIKit
import Keys

struct OAuthService {

  private static let keys = MINQKeys()
  static let clientId = keys.qiitaClientId
  static let clientSecret = keys.qiitaClientSecret
  static let urlScheme = "minq-ios"
  static let redirectTo = "\(urlScheme)://signin"
    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
  static let scope = "read_qiita write_qiita"
    .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!

  let state: String = UUID().uuidString.replacingOccurrences(of: "-", with: "_")

  var url: URL {
    let str = [
      "https://qiita.com/api/v2/oauth/authorize?",
      "&client_id=\(OAuthService.clientId)",
      "&scope=\(OAuthService.scope)",
      "&state=\(state)"
    ].joined()
    return URL(string: str)!
  }

  func process(url: URL) -> String? {
    var items = [String: String]()
    url
      .query?
      .components(separatedBy: "&")
      .map { $0.components(separatedBy: "=") }
      .forEach { keyValue in
        if let key = keyValue.first, let value = keyValue.last {
          items[key] = value
        }
    }
    if let code = items["code"], let givenState = items["state"], state == givenState {
      return code
    }
    return nil
  }

}
