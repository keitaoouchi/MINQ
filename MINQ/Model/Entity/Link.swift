import Foundation

struct Link {
  let url: URL
  let rel: Link.Relation
}

extension Link {
  enum Relation: String {
    case first
    case prev
    case next
    case last
  }
}

extension Link {

  /// RFC5988のLinkヘッダーで表現されるページネーション情報をヘッダーからパースする
  /// - Note: https://qiita.com/api/v2/docs#%E3%83%9A%E3%83%BC%E3%82%B8%E3%83%8D%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3
  static func parse(response: HTTPURLResponse?) -> [Link] {
    guard let response = response else {
      return []
    }
    if let linkHeader = response.allHeaderFields["Link"] as? String {
      return linkHeader
        .components(separatedBy: ",")
        .map { $0.components(separatedBy: ";") }
        // ['<http://qiita.com/api/v2/users?page=1>', 'rel="first"']
        .map { $0.map { $0.trimmingCharacters(in: .whitespaces) } }
        .compactMap { components -> Link? in
          guard let uriComponent = components.first,
            uriComponent.hasPrefix("<") &&
              uriComponent.hasSuffix(">") else {
                return nil
          }

          let trimmedUri = uriComponent
            .replacingOccurrences(of: "<", with: "")
            .replacingOccurrences(of: ">", with: "")

          guard let url = URL(string: trimmedUri) else {
            return nil
          }

          guard let relComponent = components.last,
            relComponent.hasPrefix("rel=") else {
              return nil
          }

          guard let relValue = relComponent
            .components(separatedBy: "=")
            .last?
            .replacingOccurrences(of: "\"", with: "") else {
              return nil
          }

          guard let rel = Link.Relation(rawValue: relValue) else {
            return nil
          }

          return Link(url: url, rel: rel)
      }
    }
    return []
  }
}
