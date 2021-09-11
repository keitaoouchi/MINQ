import RxSwift
import UIKit
import RealmSwift
import FluxxKit
import RxRelay

typealias ChannelsStore = Store<ChannelsViewModel, ChannelsViewModel.Transition>

extension ChannelsStore {
  static func make() -> ChannelsStore {
    return ChannelsStore(reducer: ChannelsViewModel.StoreReducer())
  }
}

final class ChannelsViewModel: StateType {

  let followingSection = BehaviorRelay<FollowingState>(value: .initial)
  let watchingSection = BehaviorRelay<WatchingState>(value: .initial)

  // MARK: - Reducer
  final class StoreReducer: Reducer<ChannelsViewModel, Transition> {
    override func reduce(state: ChannelsViewModel, action: Transition) {
      switch action {
      case .following(let newState):
        state.followingSection.accept(newState)
      case .channel(let newState):
        state.watchingSection.accept(newState)
      }
    }
  }

  /// Actions that occurs state transition
  enum Transition: ActionType {
    case following(to: FollowingState)
    case channel(to: WatchingState)
  }

  enum FollowingState {
    case initial
    case requesting
    case empty
    case authRequired
    case done(_ tags: [FollowingTag])
    case failed
  }

  enum WatchingState {
    case initial
    case initialized(_ tags: [FollowingTag])
    case empty
    case updated(_ tags: [FollowingTag])
  }
}

extension ChannelsViewModel {

  final class ActionCreator {
    private let store: ChannelsStore
    private var watchingTagsObservation: NotificationToken?
    private var followingTagsObservation: NotificationToken?
    private let disposeBag = DisposeBag()

    init(store: ChannelsStore) {
      self.store = store
    }

    deinit {
      self.watchingTagsObservation?.invalidate()
      self.followingTagsObservation?.invalidate()
    }

    func watch(_ tag: FollowingTag) {
      FollowingTagRepository.watch(tag)
    }

    func unwatch(_ tag: FollowingTag) {
      FollowingTagRepository.unwatch(tag)
    }

    func reorder(by tagNames: [String]) {
      try? WatchingTagRepository.reorder(by: tagNames)
    }

    func sync(_ authStored: Observable<Bool>,
              watchingTagNames: Observable<[String]>,
              and followingTags: Results<FollowingTagRecord>) {
      self.observe(watchingTagNames)
      self.observe(followingTags)
      self.observe(authStored: authStored)
    }

    private func observe(authStored: Observable<Bool>) {
      authStored.subscribe(onNext: { [weak self] isStored in
        if isStored {
          self?.request()
        } else {
          self?.store.dispatch(action: Transition.following(to: .authRequired))
        }
      }).disposed(by: self.disposeBag)
    }

    private func observe(_ watchingTagNames: Observable<[String]>) {
      watchingTagNames.subscribe(onNext: { [weak self] tagNames in
        guard !tagNames.isEmpty else {
          self?.store.dispatch(action: Transition.channel(to: .empty))
          return
        }

        let tags = tagNames.map { FollowingTag(id: $0, isWatching: true) }
        self?.store.dispatch(action: Transition.channel(to: .updated(tags)))
      }).disposed(by: disposeBag)
    }

    private func observe(_ followingTags: Results<FollowingTagRecord>) {
      self.followingTagsObservation?.invalidate()
      self.followingTagsObservation = followingTags.observe { [weak self] changes in
        switch changes {
        case .update(let liveObjects, _, let inserts, _):
          guard !liveObjects.isEmpty else {
            self?.store.dispatch(action: Transition.following(to: .empty))
            return
          }

          let tags = Array(liveObjects.compactMap { record -> FollowingTag? in
            guard let id = record.id else { return nil }
            return FollowingTag(id: id, isWatching: record.isWatching)
          })

          guard tags.count != inserts.count else {
            self?.store.dispatch(action: Transition.following(to: .done(tags)))
            return
          }

          self?.store.dispatch(action: Transition.following(to: .done(tags)))
        case .initial:
          break
        case .error:
          break
        }
      }
    }

    private func request() {
      guard authCheck() else { return }

      self.store.dispatch(action: Transition.following(to: .requesting))

      ItemTagRepository
        .findFollowedByMe(paging: Paging(page: 1, perPage: 1000))
        .subscribe(onSuccess: { [weak self] container in
          guard let self = self else { return }
          if container.contents.isEmpty {
            // TODO: ここどうしようかな？
            self.store.dispatch(action: Transition.following(to: .empty))
          } else {
            try? FollowingTagRepository.save(tags: container.contents)
          }
        }).disposed(by: self.disposeBag)
    }

    private func authCheck() -> Bool {
      if !AuthenticationRepository.isStoring {
        self.store.dispatch(action: Transition.following(to: .authRequired))
        return false
      } else {
        return true
      }
    }
  }
}
