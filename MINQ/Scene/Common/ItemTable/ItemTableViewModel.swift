import FluxxKit
import RxSwift

struct ItemTableViewModel: StateType {

  typealias ItemTableStore = Store<ItemTableViewModel, Transition>

  // MARK: - make
  static func make() -> ItemTableStore {
    return ItemTableStore(
      reducer: ItemTableViewModel.StoreReducer()
    )
  }

  // MARK: - State
  private let requestState = Variable<RequestState>(.initial)
  private let resultsState = Variable<ResultsState>(.initial)
  var viewState: Observable<ViewState> {
    return ViewState.combine(
      requestState.asObservable(),
      with: resultsState.asObservable()
    )
  }

  // MARK: - Action
  enum Transition: FluxxKit.ActionType {
    case request(to: RequestState)
    case results(to: ResultsState)
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<ItemTableViewModel, Transition> {
    override func reduce(state: ItemTableViewModel, action: Transition) {
      switch action {
      case .request(let requestState):
        state.requestState.value = requestState
      case .results(let resultsState):
        state.resultsState.value = resultsState
      }
    }
  }

  // MARK: - AsyncActionCreator
  final class AsyncActionCreator {

    private let disposeBag = DisposeBag()
    private let store: ItemTableStore
    private let query: ItemQuery

    init(store: ItemTableStore, query: ItemQuery) {
      self.store = store
      self.query = query
    }

    func load() throws {
      guard authCheck() else { return }
      guard self.store.state.requestState.value == .initial else { return }

      if let record = try ItemCollectionRecord.find(of: self.query.type), !record.isOutdated {
        store.dispatch(action: Transition.request(to: .done(paging: record.paging)))
      } else {
        self.request()
      }
    }

    func request() {
      guard authCheck() else { return }
      guard self.store.state.requestState.value != .requesting else { return }

      store.dispatch(action: Transition.request(to: .requesting))

      Item
        .find(by: query, paging: Paging(page: 1, perPage: AppInfo.perPage))
        .subscribe(
          onSuccess: { [weak self] container in
            guard let _self = self else { return }

            try? ItemCollectionRecord.save(of: _self.query.type,
                                      with: container.contents,
                                      paging: container.nextPaging)
            if container.contents.isEmpty {
              _self.store.dispatch(action: Transition.request(to: .empty))
            } else {
              _self.store.dispatch(action: Transition.request(to: .done(paging: container.nextPaging)))
            }
          }
        ).disposed(by: self.disposeBag)
    }

    func reload() {
      guard authCheck() else { return }
      guard self.store.state.requestState.value != .reloading else { return }

      store.dispatch(action: Transition.request(to: .reloading))
      Item
        .find(by: query, paging: Paging(page: 1, perPage: AppInfo.perPage))
        .subscribe(
          onSuccess: { [weak self] container in
            guard let _self = self else { return }

            // 取得データを保存
            try? ItemCollectionRecord.save(
              of: _self.query.type,
              with: container.contents,
              paging: container.nextPaging
            )

            if container.contents.isEmpty {
              _self.store.dispatch(action: Transition.request(to: .empty))
            } else {
              _self.store.dispatch(action: Transition.request(to: .done(paging: container.nextPaging)))
            }
          },
          onError: { [weak self] error in
            self?.store.dispatch(action: Transition.request(to: .failed(error: error)))
          }
        ).disposed(by: self.disposeBag)
    }

    func paginate() {
      guard authCheck() else { return }
      guard
        case .done(let nextPaging) = store.state.requestState.value,
        let paging = nextPaging else { return }

      store.dispatch(action: Transition.request(to: .paginating))
      Item
        .find(by: query, paging: paging)
        .subscribe(
          onSuccess: { [weak self] container in
            guard let _self = self else { return }

            try? ItemCollectionRecord.append(
              of: _self.query.type,
              with: container.contents,
              paging: container.nextPaging
            )
            _self.store.dispatch(action: Transition.request(to: .done(paging: container.nextPaging)))
          },
          onError: { [weak self] error in
            self?.store.dispatch(action: Transition.request(to: .failed(error: error)))
          }
        ).disposed(by: self.disposeBag)
    }

    func authCheck() -> Bool {
      if query.type.authRequired {
        if Authentication.isStored.value == false {
          store.dispatch(action: Transition.request(to: .authRequired))
          return false
        } else {
          return true
        }
      }
      return true
    }
  }
}
