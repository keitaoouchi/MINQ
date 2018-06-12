import RxSwift
import UIKit
import RealmSwift
import FluxxKit

final class MenuEditViewModel: StateType {

  typealias MenuEditStore = Store<MenuEditViewModel, Transition>

  let followingTagsState = Variable<FollowingTagsState>(.initial)
  let currentTagsState = Variable<CurrentTagsState>(.initial)

  static func make() -> MenuEditStore {
    return MenuEditStore(reducer: StoreReducer())
  }

  /// Actions that occurs state transition
  enum Transition: ActionType {
    case followingTags(state: FollowingTagsState)
    case currentTags(state: CurrentTagsState)
  }

  // MARK: - Reducer
  final class StoreReducer: Reducer<MenuEditViewModel, Transition> {
    override func reduce(state: MenuEditViewModel, action: Transition) {
      switch action {
      case .followingTags(let newState):
        state.followingTagsState.value = newState
      case .currentTags(let newState):
        state.currentTagsState.value = newState
      }
    }
  }

  enum FollowingTagsState {
    case initial
    case requesting
    case empty
    case authRequired
    case done(tags: [Tag])
    case failed
  }

  enum CurrentTagsState {
    case initial
    case initialized(tags: [Tag])
    case empty
    case update(changes: CurrentTagsChanges)
  }

  struct CurrentTagsChanges {
    let tags: [Tag]
    let insertions: [IndexPath]
    let deletions: [IndexPath]
    let modifications: [IndexPath]

    var isNotComplicatedOperation: Bool {
      guard modifications.isEmpty else { return false }
      return (insertions.isEmpty && !deletions.isEmpty) || (!insertions.isEmpty && deletions.isEmpty)
    }
  }
}

extension MenuEditViewModel {

  final class ActionCreator {

    private let store: MenuEditStore
    private var notification: NotificationToken?
    private let disposeBag = DisposeBag()

    init(store: MenuEditStore) {
      self.store = store
    }

    deinit {
      self.notification?.invalidate()
    }

    func sync(with authStored: Observable<Bool>, and tags: List<TagRecord>) {
      self.sync(with: tags)
      self.sync(with: authStored)
    }

    private func sync(with authStored: Observable<Bool>) {
      authStored.subscribe(onNext: { [weak self] isStored in
        if isStored {
          self?.request()
        } else {
          self?.store.dispatch(action: Transition.followingTags(state: .authRequired))
        }
      }).disposed(by: self.disposeBag)
    }

    private func sync(with tags: List<TagRecord>) {
      self.notification?.invalidate()
      self.notification = tags.observe { [weak self] changes in
        switch changes {
        case .update(let tags, let delets, let inserts, let modifies):
          guard !tags.isEmpty else {
            self?.store.dispatch(action: Transition.currentTags(state: .empty))
            return
          }

          guard (tags.count - inserts.count - delets.count) > 0 else {
            self?.store.dispatch(action: Transition.currentTags(state: .initialized(tags: Tag.from(records: tags))))
            return
          }

          let changes = CurrentTagsChanges(
            tags: Tag.from(records: tags),
            insertions: inserts.map { IndexPath(row: $0, section: 0) },
            deletions: delets.map { IndexPath(row: $0, section: 0) },
            modifications: modifies.map { IndexPath(row: $0, section: 0) }
          )
          self?.store.dispatch(action: Transition.currentTags(state: .update(changes: changes)))
        default:
          if tags.isEmpty {
            self?.store.dispatch(action: Transition.currentTags(state: .empty))
          } else {
            self?.store.dispatch(action: Transition.currentTags(state: .initialized(tags: Tag.from(records: tags))))
          }
        }
      }
    }

    private func request() {
      guard authCheck() else { return }

      self.store.dispatch(action: Transition.followingTags(state: .requesting))

      Tag
        .findFollowedByMe(paging: Paging(page: 1, perPage: 1000))
        .subscribe(onSuccess: { [weak self] container in
          guard let _self = self else { return }
          if container.contents.isEmpty {
            _self.store.dispatch(action: Transition.followingTags(state: .empty))
          } else {
            _self.store.dispatch(action: Transition.followingTags(state: .done(tags: container.contents)))
          }
        }).disposed(by: self.disposeBag)
    }

    private func authCheck() -> Bool {
      if Authentication.isStored.value == false {
        self.store.dispatch(action: Transition.followingTags(state: .authRequired))
        return false
      } else {
        return true
      }
    }
  }
}
