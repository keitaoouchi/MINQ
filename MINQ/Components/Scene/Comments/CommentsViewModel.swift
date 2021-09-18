import RxSwift
import FluxxKit

final class CommentsViewModel {
  let store = CommentsViewStore()
  private let actionCreator: AsyncActionCreator

  init(item: Item) {
    self.actionCreator = AsyncActionCreator(item: item, store: store)
  }
}

extension CommentsViewModel {
  func start() {
    actionCreator.load()
  }
}

extension CommentsViewModel {
  struct AsyncActionCreator {
    let item: Item
    let store: CommentsViewStore

    private let disposeBag = DisposeBag()

    init(item: Item, store: CommentsViewStore) {
      self.item = item
      self.store = store
    }

    func load() {
      CommentRepository.find(of: item).subscribe { comments in
        if comments.isEmpty {
          store.dispatch(action: CommentsViewState.Mutate.empty)
        } else {
          store.dispatch(action: CommentsViewState.Mutate.done(comments))
        }
      } onFailure: { error in
        store.dispatch(action: CommentsViewState.Mutate.failed(error))
      }.disposed(by: disposeBag)
    }
  }
}
