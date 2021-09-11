import RxSwift

final class HomeViewModel {
  let disposeBag = DisposeBag()
  var needsUpdate = false

  func observeWatchingTagsChanges() -> Disposable {
    let currentTags = WatchingTagRepository.findAllTagNames()
    return WatchingTagRepository.watchTagNames().subscribe { [weak self] tags in
      self?.needsUpdate = currentTags != tags
    }
  }
}
