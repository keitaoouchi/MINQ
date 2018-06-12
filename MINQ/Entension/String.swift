import UIKit

// Stringはnon-classなので拡張ポイント使えず
extension String {
  var minq_asURL: URL? {
    return URL(string: self)
  }
}
