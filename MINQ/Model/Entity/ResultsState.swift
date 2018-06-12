import Foundation
import RealmSwift
import FluxxKit

enum ResultsState: Equatable {
  case initial
  case empty
  case fulfilled

  static func == (lhs: ResultsState, rhs: ResultsState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):
      return true
    case (.empty, .empty):
      return true
    case (.fulfilled, .fulfilled):
      return true
    default:
      return false
    }
  }

  static func != (lhs: ResultsState, rhs: ResultsState) -> Bool {
    return !(lhs == rhs)
  }

  // MARK: - Binding
  /// Resultsを監視して結果の有無をstoreに反映させるためのBinding
  /// (状態遷移用のdispatchが叩かれることを想定)
  static func bind<T>(
    results: Results<T>,
    to store: StoreType,
    onChange: @escaping ((RealmCollectionChange<Results<T>>) -> Void),
    onEmpty: @escaping ((StoreType) -> Void),
    onFulfilled: @escaping ((StoreType) -> Void)) -> NotificationToken {
    return results.observe { [weak results] changes in
      guard let _results = results else { return }
      onChange(changes)
      switch changes {
      case .initial:
        if !_results.isEmpty {
          onFulfilled(store)
        }
      case .update:
        if _results.isEmpty {
          onEmpty(store)
        } else {
          onFulfilled(store)
        }
      default:
        break
      }
    }
  }
}
