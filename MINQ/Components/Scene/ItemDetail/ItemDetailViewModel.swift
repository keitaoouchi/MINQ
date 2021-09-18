import FluxxKit
import RxSwift
import RxRelay
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
    case done
    case failed
  }

  enum CheckState {
    case initial
    case checked
    case unchecked
  }

  // MARK: - State
  let viewState = BehaviorRelay<ItemDetailState>(value: .initial)
  let progress = BehaviorRelay<Float>(value: 0.0)
  let likeButtonState = BehaviorRelay<CheckState>(value: .initial)
  let stockButtonState = BehaviorRelay<CheckState>(value: .initial)

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
        state.viewState.accept(newState)
      case .progress(let newProgress):
        state.progress.accept(newProgress)
      case .setLikeState(let newState):
        state.likeButtonState.accept(newState)
      case .setStockState(let newState):
        state.stockButtonState.accept(newState)
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
      guard store.state.viewState.value != .loading else { return }

      timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
        guard let progress = self?.store.state.progress.value else { return }

        guard progress < 0.9 else { return }

        let delta: Float = (progress > 0.5) ? 0.001 : 0.005
        self?.store.dispatch(action: Action.progress(to: progress + delta))
      }

      DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
        self?.stopProgress()
        guard let self = self, self.store.state.viewState.value == .loading else {
          return
        }

        self.store.dispatch(action: Action.transition(to: .failed))
      }
    }

    func stopProgress() {
      timer?.invalidate()
    }

    func checkStockAndLikes(item: Item) {
      guard AuthenticationRepository.isStoring else { return }
      ItemRepository.isLiked(item).subscribe(onSuccess: { isLiked in
        self.store.dispatch(action: Action.setLikeState(to: isLiked ? .checked : .unchecked))
      }).disposed(by: self.disposeBag)

      ItemRepository.isStocked(item).subscribe(onSuccess: { isStocked in
        self.store.dispatch(action: Action.setStockState(to: isStocked ? .checked : .unchecked))
      }).disposed(by: self.disposeBag)
    }

    func like(item: Item) {
      guard AuthenticationRepository.isStoring else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      store.dispatch(action: Action.setLikeState(to: .initial))
      ItemRepository.like(item).subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setLikeState(to: .checked))
        AnalyticsService.log(event: .like(itemId: item.id))
        ReviewRequestService.liked()
      }).disposed(by: disposeBag)
    }

    func unlike(item: Item) {
      guard AuthenticationRepository.isStoring else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      store.dispatch(action: Action.setLikeState(to: .initial))
      ItemRepository.unlike(item).subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setLikeState(to: .unchecked))
      }).disposed(by: disposeBag)
    }

    func stock(item: Item) {
      guard AuthenticationRepository.isStoring else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      store.dispatch(action: Action.setStockState(to: .initial))
      ItemRepository.stock(item).subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setStockState(to: .checked))
        AnalyticsService.log(event: .stock(itemId: item.id))
        ReviewRequestService.stocked()
      }).disposed(by: disposeBag)
    }

    func unstock(item: Item) {
      guard AuthenticationRepository.isStoring else {
        Dispatcher.shared.dispatch(action: AppRootViewModel.Action.signin)
        return
      }
      store.dispatch(action: Action.setStockState(to: .initial))
      ItemRepository.unstock(item).subscribe(onSuccess: { [weak self] _ in
        self?.store.dispatch(action: Action.setStockState(to: .unchecked))
      }).disposed(by: disposeBag)
    }
  }
}
