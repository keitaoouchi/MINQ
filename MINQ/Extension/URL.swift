import UIKit

// URLはnon-classなので拡張ポイント使えず
extension URL {
  var minq_queryDictionary: [String: String] {
    var items = [String: String]()
    self
      .query?
      .components(separatedBy: "&")
      .map { $0.components(separatedBy: "=") }
      .forEach { keyValue in
        if let key = keyValue.first, let value = keyValue.last {
          items[key] = value
        }
    }
    return items
  }

  var minq_isQiitaItem: Bool {
    let components = self.pathComponents
    return self.host == "qiita.com" && components.count == 4 && components[2] == "items"
  }

  var minq_qiitaItemId: String? {
    if minq_isQiitaItem {
      return self.pathComponents.last
    } else {
      return nil
    }
  }
}
