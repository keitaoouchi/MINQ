import RxSwift
import FluxxKit

struct AppRootViewModel: StateType {

  typealias AppRootStore = Store<AppRootViewModel, Action>

  // MARK: - make
  static func make() -> AppRootStore {
    return AppRootStore(
      reducer: AppRootViewModel.StoreReducer()
    )
  }

  /// RKDropdownAlertでドロップダウン表示するメッセージ種
  enum MessageType {
    case success(message: String)
    case alert(message: String)
  }

  // MARK: - State
  let messageStream = PublishSubject<MessageType>()
  let signinTrigger = PublishSubject<Void>()
  let resetTrigger = PublishSubject<Bool>()

  // MARK: - Action
  enum Action: ActionType {
    case show(message: MessageType)
    case reset(force: Bool)
    case signin
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<AppRootViewModel, Action> {
    override func reduce(state: AppRootViewModel, action: AppRootViewModel.Action) {
      switch action {
      case .show(let message):
        state.messageStream.onNext(message)
      case .signin:
        state.signinTrigger.onNext(())
      case .reset(let force):
        state.resetTrigger.onNext(force)
      }
    }
  }
}
