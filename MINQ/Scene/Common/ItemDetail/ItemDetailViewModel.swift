import FluxxKit
import RxSwift
import UIKit

struct ItemDetailViewModel: StateType {

  typealias ItemDetailStore = Store<ItemDetailViewModel, Action>

  // MARK: - make
  static func make() -> ItemDetailStore {
    return Store<ItemDetailViewModel, Action>(
      reducer: ItemDetailViewModel.StoreReducer()
    )
  }

  enum ItemDetailState {
    case initial
    case loading
    case requesting
    case done
    case failed
  }

  enum CheckState {
    case initial
    case checked
    case unchecked
  }

  // MARK: - State
  let viewState = Variable<ItemDetailState>(.initial)
  let progress = Variable<Float>(0.0)
  let likeButtonState = Variable<CheckState>(.initial)
  let stockButtonState = Variable<CheckState>(.initial)

  // MARK: - Action
  enum Action: FluxxKit.ActionType {
    case transition(to: ItemDetailState)
    case progress(to: Float)
    case setLikeState(to: CheckState)
    case setStockState(to: CheckState)
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<ItemDetailViewModel, Action> {
    override func reduce(state: ItemDetailViewModel, action: Action) {
      switch action {
      case .transition(let newState):
        state.viewState.value = newState
      case .progress(let newProgress):
        state.progress.value = newProgress
      case .setLikeState(let newState):
        state.likeButtonState.value = newState
      case .setStockState(let newState):
        state.stockButtonState.value = newState
      }
    }
  }

  // MARK: - AsyncActionCreator
  final class AsyncActionCreator {

    private let disposeBag = DisposeBag()
    private let store: ItemDetailStore
    private var timer: Timer?

    init(store: ItemDetailStore) {
      self.store = store
    }

    deinit {
      timer?.invalidate()
    }

    func startProgress() {
      guard self.store.state.viewState.value != .loading else { return }

      self.timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
        guard let progress = self?.store.state.progress.value else { return }

        guard progress < 0.9 else { return }

        let delta: Float = (progress > 0.5) ? 0.001 : 0.005
        self?.store.dispatch(action: Action.progress(to: progress + delta))
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
        self?.stopProgress()
        guard let _self = self, _self.store.state.viewState.value == .loading else {
          return
        }

        _self.store.dispatch(action: Action.transition(to: .failed))
      }
    }

    func stopProgress() {
      self.timer?.invalidate()
    }

    func checkStockAndLikes(item: Item) {
      item.isLiked().subscribe(onSuccess: { isLiked in
        self.store.dispatch(action: Action.setLikeState(to: isLiked ? .checked : .unchecked))
      }).disposed(by: self.disposeBag)

      item.isStocked().subscribe(onSuccess: { isStocked in
        self.store.dispatch(action: Action.setStockState(to: isStocked ? .checked : .unchecked))
      }).disposed(by: self.disposeBag)
    }

    func load(by id: String) throws {
      guard self.store.state.viewState.value != .requesting else { return }

      if let itemRecord = try ItemRecord.find(by: id) {
        store.dispatch(action: Action.transition(to: .done))
        Dispatcher.shared.dispatch(action: Navigator.Link.item(item: itemRecord))
      } else {
        self.request(by: id)
      }
    }

    func request(by id: String) {
      guard self.store.state.viewState.value != .requesting else { return }

      store.dispatch(action: Action.transition(to: .requesting))

      Item
        .find(by: id)
        .subscribe(
          onSuccess: { [weak self] container in
            try? ItemRecord.save(entity: container.content)
            self?.store.dispatch(action: Action.transition(to: .done))
            let itemRecord = try! ItemRecord.find(by: id)!
            Dispatcher.shared.dispatch(action: Navigator.Link.item(item: itemRecord))
          }
        ).disposed(by: self.disposeBag)
    }

    func like(item: Item) {
      guard Authentication.isStored.value == true else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      self.store.dispatch(action: Action.setLikeState(to: .initial))
      item.like().subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setLikeState(to: .checked))
        AnalyticsService.log(event: .like(itemId: item.id))
      }).disposed(by: self.disposeBag)
    }

    func unlike(item: Item) {
      guard Authentication.isStored.value == true else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      self.store.dispatch(action: Action.setLikeState(to: .initial))
      item.unlike().subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setLikeState(to: .unchecked))
      }).disposed(by: self.disposeBag)
    }

    func stock(item: Item) {
      guard Authentication.isStored.value == true else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      self.store.dispatch(action: Action.setStockState(to: .initial))
      item.stock().subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setStockState(to: .checked))
        AnalyticsService.log(event: .stock(itemId: item.id))
      }).disposed(by: self.disposeBag)
    }

    func unstock(item: Item) {
      guard Authentication.isStored.value == true else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      self.store.dispatch(action: Action.setStockState(to: .initial))
      item.unstock().subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setStockState(to: .unchecked))
      }).disposed(by: self.disposeBag)
    }
  }
}
