import Foundation

struct RateLimit {
  let limit: Int
  let remaining: Int
  let reset: Int
}

extension RateLimit {

  /// RFC5988のLinkヘッダーで表現されるページネーション情報をヘッダーからパースする
  /// - Note: https://qiita.com/api/v2/docs#%E3%83%9A%E3%83%BC%E3%82%B8%E3%83%8D%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3
  static func parse(response: HTTPURLResponse?) -> RateLimit? {
    guard let response = response else {
      return nil
    }

    if let limitVal = response.allHeaderFields["rate-limit"] as? String,
       let remainingVal = response.allHeaderFields["rate-remaining"] as? String,
       let resetVal = response.allHeaderFields["rate-reset"] as? String,
       let limit = Int(limitVal),
       let remaining = Int(remainingVal),
       let reset = Int(resetVal) {
      return RateLimit(limit: limit, remaining: remaining, reset: reset)
    }

    return nil
  }
}
