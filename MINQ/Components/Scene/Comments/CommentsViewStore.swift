import FluxxKit
import RxSwift
import RxRelay

typealias CommentsViewStore = Store<CommentsViewState, CommentsViewState.Mutate>

extension CommentsViewStore {
  convenience init() {
    self.init(reducer: CommentsViewState.StoreReducer())
  }
}

struct CommentsViewState: StateType {
  let requestState = BehaviorRelay<State>(value: .requesting)

  enum State {
    case requesting
    case empty
    case failed(_ error: Error)
    case done(_ comments: [Comment])
  }

  enum Mutate: ActionType {
    case empty
    case failed(_ error: Error)
    case done(_ comments: [Comment])
  }

  final class StoreReducer: Reducer<CommentsViewState, Mutate> {
    override func reduce(state: CommentsViewState, action: Mutate) {
      switch action {
      case .empty:
        state.requestState.accept(.empty)
      case .failed(let error):
        state.requestState.accept(.failed(error))
      case .done(let comments):
        state.requestState.accept(.done(comments))
      }
    }
  }
}
