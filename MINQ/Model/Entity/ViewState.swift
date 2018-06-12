import Foundation
import RxSwift

enum ViewState: Equatable {
  case initial
  case authRequired
  case requesting
  case reloading
  case paginating
  case failed(error: Error)
  case empty
  case done(paging: Paging?)

  static func == (lhs: ViewState, rhs: ViewState) -> Bool {
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

  static func != (lhs: ViewState, rhs: ViewState) -> Bool {
    return !(lhs == rhs)
  }
}

extension ViewState {

  private static func combine(
    requestState: RequestState,
    resultsState: ResultsState) -> ViewState {
    switch requestState {
    case .initial:
      return .initial
    case .authRequired:
      return .authRequired
    case .empty:
      switch resultsState {
      case .initial:
        return .empty
      case .empty:
        return .empty
      case .fulfilled:
        return .done(paging: nil)
      }
    case .paginating:
      return .paginating
    case .reloading:
      return .reloading
    case .requesting:
      return .requesting
    case .failed(let error):
      return .failed(error: error)
    case .done(let paging):
      switch resultsState {
      case .initial:
        return .done(paging: paging)
      case .empty:
        return .empty
      case .fulfilled:
        return .done(paging: paging)
      }
    }
  }

  static func combine(
    _ requestStream: Observable<RequestState>,
    with resultsStream: Observable<ResultsState>) -> Observable<ViewState> {
    return Observable.combineLatest(
      requestStream,
      resultsStream,
      resultSelector: { (requestState, resultsState) -> ViewState in
        return combine(requestState: requestState, resultsState: resultsState)
      }
    )
  }
}
