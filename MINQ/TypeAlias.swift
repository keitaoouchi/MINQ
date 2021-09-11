import UIKit
import RealmSwift

typealias OnTapReloader = ((UIControl) -> Void)

typealias ItemCollectionChanges = RealmCollectionChange<List<ItemRecord>>

extension ItemCollectionChanges {
  var identifiers: [String] {
    switch self {
    case .initial(let r): return Array(r.compactMap { $0.id })
    case .update(let r, _, _, _): return Array(r.compactMap { $0.id })
    case .error: return []
    }
  }
}
