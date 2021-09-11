import RxSwift
import RxCocoa
import FluxxKit

struct SettingsViewModel: StateType {

  typealias SettingsStore = Store<SettingsViewModel, Transition>

  enum ViewState {
    case initial
    case anonymouse
    case signed(user: User)
    case requesting
    case failed
  }

  let viewState = BehaviorRelay<ViewState>(value: .initial)

  static func make() -> SettingsStore {
    return SettingsStore(reducer: StoreReducer())
  }

  // MARK: - Action
  enum Transition: ActionType {
    case view(to: ViewState)
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<SettingsViewModel, Transition> {
    override func reduce(state: SettingsViewModel, action: Transition) {
      switch action {
      case .view(let newState):
        state.viewState.accept(newState)
      }
    }
  }
}

extension SettingsViewModel {

  struct ActionCreator {

    let store: SettingsStore
    private let disposeBag = DisposeBag()

    init(store: SettingsStore) {
      self.store = store
    }

    func signout() {
      UserRepository.clearMe()
      try? ItemRepository.clear(type: .mine)
      try? ItemRepository.clear(type: .stocks)
      AuthenticationRepository.destroy().subscribe(onSuccess: { _ in
        Dispatcher.shared.dispatch(
          action: AppRootViewModel.Action.show(
            message: .success(message: L10n.loggedOut)))
      }).disposed(by: disposeBag)
    }

    func clearCache() {
      Dispatcher.shared.dispatch(action: AppRootViewModel.Action.reset(force: false))
    }

    func sync(with authStored: BehaviorRelay<Bool>) {
      authStored.asObservable().subscribe(onNext: { isStored in
        if isStored {
          store.dispatch(action: SettingsViewModel.Transition.view(to: .requesting))
          UserRepository.whoami().subscribe(
            onSuccess: { userContainer in
              store.dispatch(action: SettingsViewModel.Transition.view(to: .signed(user: userContainer.content)))
          },
            onError: { _ in
              store.dispatch(action: SettingsViewModel.Transition.view(to: .failed))
          }
            ).disposed(by: disposeBag)
        } else {
          store.dispatch(action: SettingsViewModel.Transition.view(to: .anonymouse))
        }
      }).disposed(by: disposeBag)
    }
  }
}
