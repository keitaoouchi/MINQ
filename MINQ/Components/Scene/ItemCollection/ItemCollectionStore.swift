import FluxxKit
import RxRelay
import RxSwift
import RealmSwift

typealias ItemCollectionStore = Store<ItemCollectionState, ItemCollectionState.Mutate>

extension ItemCollectionStore {
  // MARK: - make
  static func make() -> ItemCollectionStore {
    return ItemCollectionStore(
      reducer: ItemCollectionState.StoreReducer()
    )
  }
}

struct ItemCollectionState: StateType {

  // MARK: - State
  let requestState = BehaviorRelay<RequestState>(value: .initial)
  var watchingState = BehaviorRelay<WatchingState>(value: .unknown)
  let disposeBag = DisposeBag()

  // MARK: - Action
  enum Mutate: FluxxKit.ActionType {
    case requestState(to: RequestState)
    case watchState(to: WatchingState)
    case updateContents(identifiers: [String])
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<ItemCollectionState, Mutate> {
    override func reduce(state: ItemCollectionState, action: Mutate) {
      switch action {
      case .requestState(let newState):
        state.requestState.accept(newState)
      case .watchState(let newState):
        state.watchingState.accept(newState)
      case .updateContents(let identifiers):
        switch state.requestState.value {
        case .done(let pagingState), .loaded(let pagingState, _):
          state.requestState.accept(.loaded(pagingState: pagingState, identifiers: identifiers))
        default:
          Debugger.shared.info("[QuerySkipped] requestState:  \(state.requestState.value), queryState: \(identifiers)")
        }
      }
    }
  }

  // MARK: - AsyncActionCreator
  final class AsyncActionCreator {

    private let disposeBag = DisposeBag()
    private let store: ItemCollectionStore
    private let query: ItemQuery

    init(store: ItemCollectionStore, query: ItemQuery) {
      self.store = store
      self.query = query
    }

    func load(avoidCache: Bool) throws {
      guard authCheck() else { return }
      guard self.store.state.requestState.value == .initial else { return }

      if avoidCache {
        self.request()
      } else if let container = ItemRepository.findCachedItems(of: query.type), !container.contents.isEmpty {
        let paging = Paging(page: container.contents.count / Constant.perPage + 1, perPage: Constant.perPage)
        store.dispatch(action: Mutate.requestState(to: .done(pagingState: .newPage(paging: paging))))
      } else {
        self.request()
      }
    }

    func restore() {
      switch store.state.requestState.value {
      case .failed(_, let pagingState) where pagingState.isPaginatable:
        paginate(force: true)
      default:
        reload()
      }
    }

    func request() {
      guard authCheck() else { return }
      guard !self.store.state.requestState.value.isRequesting else { return }

      store.dispatch(action: Mutate.requestState(to: .requesting(.normal)))

      let paging = Paging(page: 1, perPage: Constant.perPage)
      fetchItems(paging: paging)
    }

    func reload() {
      guard authCheck() else { return }
      guard !self.store.state.requestState.value.isRequesting else { return }

      store.dispatch(action: Mutate.requestState(to: .requesting(.pullToRefresh)))
      let paging = Paging(page: 1, perPage: Constant.perPage)
      fetchItems(paging: paging, clean: true)
    }

    func paginate(force: Bool) {
      guard authCheck() else { return }
      let p: PagingState?
      switch self.store.state.requestState.value {
      case .loaded(let pagingState, _):
        p = pagingState
      case .failed(_, let pagingState) where force:
        p = pagingState
      default:
        p = nil
      }
      guard case let .newPage(paging) = p, paging.page > 1 else { return }

      store.dispatch(action: Mutate.requestState(to: .requesting(.pagination)))
      fetchItems(paging: paging)
    }

    func fetchItems(paging: Paging, clean: Bool = false) {
      ItemRepository
        .find(by: query, paging: paging)
        .subscribe(
          onSuccess: { [weak self] container in
            guard let self = self else { return }

            if paging.page == 1 && container.contents.isEmpty {
              self.store.dispatch(action: Mutate.requestState(to: .empty))
            } else {
              self.store.dispatch(action: Mutate.requestState(to: .done(pagingState: container.nextPage)))
            }

            if clean {
              try? ItemRepository.save(of: self.query.type, with: container.contents)
            } else {
              try? ItemRepository.append(of: self.query.type, with: container.contents)
            }
          },
          onFailure: { [weak self] error in
            self?.store.dispatch(action: Mutate.requestState(to: .failed(error: error, pagingState: .newPage(paging: paging))))
          }
        ).disposed(by: self.disposeBag)
    }

    func authCheck() -> Bool {
      if query.type.authRequired {
        if !AuthenticationRepository.isStoring {
          store.dispatch(action: Mutate.requestState(to: .authRequired))
          return false
        } else {
          return true
        }
      }
      return true
    }

    func syncMenu() {
      switch query.type {
      case .tag(let tag):
        WatchingTagRepository.observe(tagName: tag.name).subscribe(onNext: { isWatching in
          if isWatching {
            self.store.dispatch(action: Mutate.watchState(to: .watching))
          } else {
            self.store.dispatch(action: Mutate.watchState(to: .notWatching))
          }
        }).disposed(by: disposeBag)
      default:
        break
      }
    }

    func addTag() {
      switch query.type {
      case .tag(let tag):
        try? WatchingTagRepository.append(tag: tag)
      default:
        break
      }
    }

    func removeTag() {
      switch query.type {
      case .tag(let tag):
        try? WatchingTagRepository.remove(named: tag.name)
      default:
        break
      }
    }
  }
}
