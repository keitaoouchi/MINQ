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
    case (.loaded(let lPage, let lIdentifiers), .loaded(let rPage, let rIdentifiers)):
      return lPage == rPage && lIdentifiers == rIdentifiers
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
    default:
      return false
    }
  }

  case newPage(paging: Paging)
  case noPage

  var isPaginatable: Bool {
    switch self {
    case .newPage(let paging): return paging.page > 1
    case .noPage: return false
    }
  }

  var isPageOne: Bool {
    switch self {
    case .newPage(let paging): return paging.page == 1
    default: return false
    }
  }
}
