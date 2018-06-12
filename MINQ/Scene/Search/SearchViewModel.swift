import FluxxKit
import RxSwift

struct SearchViewModel: StateType {

  typealias SearchStore = Store<SearchViewModel, Action>

  // MARK: - make
  static func make() -> SearchStore {
    return SearchStore(
      reducer: SearchViewModel.StoreReducer()
    )
  }

  // MARK: - State
  let query = PublishSubject<String>()
  let unfocusSignal = PublishSubject<Void>()

  // MARK: - Action
  enum Action: FluxxKit.ActionType {
    case updateQuery(query: String)
    case unfocus
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<SearchViewModel, Action> {
    override func reduce(state: SearchViewModel, action: SearchViewModel.Action) {
      switch action {
      case .updateQuery(let string):
        state.query.onNext(string)
      case .unfocus:
        state.unfocusSignal.onNext(())
      }
    }
  }
}
