import Foundation
import RxSwift

enum RequestState: Equatable {
  case initial
  case authRequired
  case requesting
  case reloading
  case paginating
  case failed(error: Error)
  case empty
  case done(paging: Paging?)

  static func == (lhs: RequestState, rhs: RequestState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):
      return true
    case (.requesting, .requesting):
      return true
    case (.reloading, .reloading):
      return true
    case (.empty, .empty):
      return true
    case (.done, .done):
      return true
    default:
      return false
    }
  }

  static func != (lhs: RequestState, rhs: RequestState) -> Bool {
    return !(lhs == rhs)
  }
}
