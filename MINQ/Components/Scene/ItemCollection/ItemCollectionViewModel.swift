import Foundation
import RealmSwift
import RxRelay
import RxSwift

final class ItemCollectionViewModel {
  let query: ItemQuery
  let store: ItemCollectionStore
  let actionCreator: ItemCollectionState.AsyncActionCreator
  private let disposeBag = DisposeBag()

  init(query: ItemQuery) {
    self.query = query
    store = ItemCollectionStore.make()
    actionCreator = ItemCollectionState.AsyncActionCreator(
      store: store,
      query: query
    )
  }

  func start(avoidCache: Bool) {
    ItemRepository.watchItems(of: query.type).subscribe(on: MainScheduler.instance).subscribe { [weak self] identifiers in
      self?.store.dispatch(action: ItemCollectionState.Mutate.updateContents(identifiers: identifiers))
    }.disposed(by: disposeBag)

    try? actionCreator.load(avoidCache: avoidCache)
    actionCreator.syncMenu()
  }
}