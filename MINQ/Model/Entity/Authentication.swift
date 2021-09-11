import Moya
import RxSwift
import RxRelay
import KeychainAccess

/// 認証情報
struct Authentication: MINQCodable {
  let accessToken: String

  enum CodingKeys: String, CodingKey {
    case accessToken = "token"
  }
}
