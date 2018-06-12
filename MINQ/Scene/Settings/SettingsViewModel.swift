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

  let viewState = Variable<ViewState>(.initial)

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
        state.viewState.value = newState
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
      Authentication.destroy().subscribe(onSuccess: { _ in
        Dispatcher.shared.dispatch(
          action: AppRootViewModel.Action.show(
            message: .success(message: "ログアウトしました")))
      }).disposed(by: self.disposeBag)
    }

    func clearCache() {
      Dispatcher.shared.dispatch(action: AppRootViewModel.Action.reset)
    }

    func sync(with authStored: Variable<Bool>) {
      authStored.asObservable().subscribe(onNext: { isStored in
        if isStored {
          self.store.dispatch(action: SettingsViewModel.Transition.view(to: .requesting))
          User.whoami().subscribe(
            onSuccess: { userContainer in
              self.store.dispatch(action: SettingsViewModel.Transition.view(to: .signed(user: userContainer.content)))
          },
            onError: { _ in
              self.store.dispatch(action: SettingsViewModel.Transition.view(to: .failed))
          }
            ).disposed(by: self.disposeBag)
        } else {
          self.store.dispatch(action: SettingsViewModel.Transition.view(to: .anonymouse))
        }
      }).disposed(by: self.disposeBag)
    }
  }
}
