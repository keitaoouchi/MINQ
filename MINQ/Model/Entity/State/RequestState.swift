import Foundation
import RxSwift

enum RequestState: Equatable {
  case initial
  case authRequired
  case requesting(_ type: RequestType)
  case failed(error: Error, pagingState: PagingState)
  case empty
  case done(pagingState: PagingState)
  case loaded(pagingState: PagingState, identifiers: [String])

  static func == (lhs: RequestState, rhs: RequestState) -> Bool {
    switch (lhs, rhs) {
    case (.initial, .initial):
      return true
    case (.authRequired, .authRequired):
      return true
    case (.requesting, .requesting):
      return true
    case (.empty, .empty):
      return true
    case (.done, .done):
      return true
    default:
      return false
    }
  }

  var isRequesting: Bool {
    switch self {
    case .requesting: return true
    default: return false
    }
  }
}

enum RequestType: Equatable {
  case pullToRefresh
  case normal
  case pagination
}

enum PagingState: Equatable {
  static func == (lhs: PagingState, rhs: PagingState) -> Bool {
    switch (lhs, rhs) {
    case let (.newPage(leftPage), .newPage(rightPage)):
      return leftPage == rightPage
    case (.noPage, .noPage):
      return true
    case (.fromCached, .fromCached):
      return true
    default:
      return false
    }
  }

  case newPage(paging: Paging)
  case noPage
  case fromCached

  var isPaginatable: Bool {
    switch self {
    case .newPage(let paging): return paging.page > 1
    case .noPage: return false
    case .fromCached: return false
    }
  }

  var isPageOne: Bool {
    switch self {
    case .newPage(let paging): return paging.page == 1
    default: return false
    }
  }
}
