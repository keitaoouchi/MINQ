import UIKit
import RxCocoa
import RxSwift
import FluxxKit

// MARK: - Properties
final class ChannelsViewController: UICollectionViewController {
  private lazy var dataSource = DataSource(
    collectionView: collectionView,
    cellProvider: cellProvider)

  private lazy var actionCreator = ChannelsViewModel.ActionCreator(store: store)

  private let store = ChannelsStore.make()

  private let disposeBag = DisposeBag()

  init() {
    super.init(collectionViewLayout: ChannelsViewController.layout)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Lifecycle
extension ChannelsViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    configureUI()
    bind()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    actionCreator.sync(
      AuthenticationRepository.storing.asObservable(),
      watchingTagNames: WatchingTagRepository.watchTagNames(),
      and: FollowingTagRepository.all()
    )
  }
}

// MARK: - Layout & UISettings
private extension ChannelsViewController {
  func configureUI() {
    collectionView.register(cellType: ChannelCell.self)
    collectionView.register(cellType: EmptyCell.self)
    collectionView.register(cellType: AuthRequiredCell.self)
    collectionView.register(cellType: LoadingCell.self)
    collectionView.register(cellType: FailedCell.self)
    collectionView.register(supplementaryViewType: ChannelHeader.self, ofKind: UICollectionView.elementKindSectionHeader)
    collectionView.isEditing = true
    dataSource.supplementaryViewProvider = ChannelsViewController.supplementaryViewProvider
    var snapshot = Snapshot()
    snapshot.appendSections([.watching, .following])
    dataSource.apply(snapshot)

    dataSource.reorderingHandlers.canReorderItem = { _ in return true }
    dataSource.reorderingHandlers.didReorder = { [weak self] transaction in
      let tags = transaction.finalSnapshot.itemIdentifiers(inSection: Section.watching)
      let tagNames = tags.compactMap { tag -> String? in
        switch tag.contentType {
        case .tag(let watchingTag): return watchingTag.id
        default: return nil
        }
      }
      self?.actionCreator.reorder(by: tagNames)
    }
  }

  static let layout: UICollectionViewCompositionalLayout = {
    var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
    config.headerMode = .supplementary
    config.showsSeparators = false
    config.backgroundColor = Asset.Colors.bg.color
    return UICollectionViewCompositionalLayout.list(using: config)
  }()

  var cellProvider: DataSource.CellProvider {
    { [weak self] collectionView, indexPath, sectionTag in
      switch sectionTag.contentType {
      case .tag(let tag):
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ChannelCell
        cell.apply(tag: tag)

        switch indexPath.section {
        case 0:
          cell.accessories = [
            .delete(actionHandler: { [weak self] in
              self?.actionCreator.unwatch(tag)
            }),
            .reorder()
          ]
        case 1:
          cell.accessories = [
            .insert(options: .init(isHidden: tag.isWatching), actionHandler: {  [weak self] in
              self?.actionCreator.watch(tag)
            })
          ]
        default:
          break
        }
        return cell
      case .empty:
        return collectionView.dequeueReusableCell(for: indexPath) as EmptyCell
      case .authRequired:
        return collectionView.dequeueReusableCell(for: indexPath) as AuthRequiredCell
      case .requesting:
        return collectionView.dequeueReusableCell(for: indexPath) as LoadingCell
      case .failed:
        return collectionView.dequeueReusableCell(for: indexPath) as FailedCell
      }
    }
  }

  static let supplementaryViewProvider: DataSource.SupplementaryViewProvider = { collectionView, elementKind, indexPath in
    if elementKind == UICollectionView.elementKindSectionHeader {
      let header = collectionView.dequeueReusableSupplementaryView(ofKind: elementKind, for: indexPath) as ChannelHeader
      let title = indexPath.section == 0 ? L10n.currentChannels : L10n.followingTags
      header.apply(title)
      return header
    } else {
      return nil
    }
  }
}

// MARK: - Bind
private extension ChannelsViewController {
  func bind() {
    store.state.watchingSection.subscribe(onNext: { [weak self] state in
      self?.updateWatching(state: state)
    }).disposed(by: disposeBag)

    store.state.followingSection.subscribe(onNext: { [weak self] state in
      self?.updateFollowing(state: state)
    }).disposed(by: disposeBag)
  }

  func updateWatching(state: ChannelsViewModel.WatchingState) {
    var snapshot = dataSource.snapshot(for: .watching)
    switch state {
    case .initial:
      break
    case .empty:
      snapshot.deleteAll()
      snapshot.append([SectionTag(contentType: .empty, section: .watching)])
      self.dataSource.apply(snapshot, to: .watching, animatingDifferences: false)
    case .initialized(let tags):
      snapshot.deleteAll()
      let watchings = tags
        .map { SectionTag(contentType: .tag($0), section: .watching)}
      snapshot.append(watchings)
      dataSource.apply(snapshot, to: .watching, animatingDifferences: false)
    case .updated(let tags):
      snapshot.deleteAll()
      let watchings = tags
        .map { FollowingTag(id: $0.id, isWatching: true) }
        .map { SectionTag(contentType: .tag($0), section: .watching)}
      snapshot.append(watchings)
      dataSource.apply(snapshot, to: .watching, animatingDifferences: true)
    }
  }

  func updateFollowing(state: ChannelsViewModel.FollowingState) {
    var snapshot = dataSource.snapshot(for: .following)
    switch state {
    case .done(let tags):
      let newTags = tags.map { SectionTag(contentType: .tag($0), section: .following) }
      guard snapshot.items != newTags else { return }
      snapshot.deleteAll()
      snapshot.append(newTags)
      dataSource.apply(snapshot, to: .following, animatingDifferences: true)
    case .initial:
      snapshot.deleteAll()
      snapshot.append([SectionTag(contentType: .requesting, section: .following)])
      dataSource.apply(snapshot, to: .following, animatingDifferences: true)
    case .requesting:
      snapshot.deleteAll()
      snapshot.append([SectionTag(contentType: .requesting, section: .following)])
      dataSource.apply(snapshot, to: .following, animatingDifferences: true)
    case .authRequired:
      snapshot.deleteAll()
      snapshot.append([SectionTag(contentType: .authRequired, section: .following)])
      dataSource.apply(snapshot, to: .following, animatingDifferences: true)
    case .empty:
      snapshot.deleteAll()
      snapshot.append([SectionTag(contentType: .empty, section: .following)])
      dataSource.apply(snapshot, to: .following, animatingDifferences: true)
    case .failed:
      snapshot.deleteAll()
      snapshot.append([SectionTag(contentType: .failed, section: .following)])
      dataSource.apply(snapshot, to: .following, animatingDifferences: true)
    }
  }
}

// MARK: - Misc
extension ChannelsViewController {
  enum Section {
    case watching
    case following
  }

  enum ContentType: Hashable {
    static func == (lhs: ContentType, rhs: ContentType) -> Bool {
      switch (lhs, rhs) {
      case (.requesting, .requesting): return true
      case (.empty, .empty): return true
      case (.authRequired, .authRequired): return true
      case (.tag(let lt), .tag(let rt)): return lt == rt
      default: return false
      }
    }

    case tag(_ tag: FollowingTag)
    case empty
    case authRequired
    case failed
    case requesting
  }

  typealias DataSource = UICollectionViewDiffableDataSource<Section, SectionTag>
  typealias Snapshot = NSDiffableDataSourceSnapshot<Section, SectionTag>

  /// Section間で重複したTagを別物として扱う
  struct SectionTag: Hashable {
    let contentType: ContentType
    let section: ChannelsViewController.Section
  }
}
