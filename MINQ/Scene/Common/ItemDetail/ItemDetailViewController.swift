import UIKit
import MarkdownView
import Kingfisher
import WebKit
import RxSwift
import FluxxKit
import HTMLString
import RealmSwift

final class ItemDetailViewController: UIViewController {

  @IBOutlet weak var mainScroller: UIScrollView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var likesMarkLabel: UILabel!
  @IBOutlet weak var likesCountLabel: UILabel!
  @IBOutlet weak var commentsMarkLabel: UILabel!
  @IBOutlet weak var commentsCountLabel: UILabel!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userImageView: UIImageView!
  @IBOutlet weak var userButton: UIButton!
  @IBOutlet weak var contentView: UIView!
  @IBOutlet weak var tagsStackView: UIStackView!
  @IBOutlet weak var tagsScroller: UIScrollView!
  @IBOutlet weak var createdDateLabel: UILabel!
  @IBOutlet var sorryView: UIView!
  @IBOutlet weak var sorryImage: UIImageView!
  @IBOutlet weak var progressBar: UIProgressView!

  private lazy var likeButton: UIBarButtonItem = {
    return UIBarButtonItem(image: AppInfo.unlikedImage, style: .done, target: self, action: nil)
  }()

  private lazy var stockButton: UIBarButtonItem = {
    return UIBarButtonItem(image: AppInfo.unstockedImage, style: .done, target: self, action: nil)
  }()

  private lazy var safariButton: UIBarButtonItem = {
    return UIBarButtonItem(image: AppInfo.safariImage, style: .done, target: self, action: #selector(openInSafari))
  }()

  private var itemRecord: ItemRecord! {
    didSet {
      self.item = Item(record: itemRecord)!
    }
  }
  private(set) var item: Item!

  private var loader: LoadingStateView?
  private let disposeBag = DisposeBag()
  private let markdownView = MarkdownView()
  private(set) var store: ItemDetailViewModel.ItemDetailStore!
  private(set) var actionCreator: ItemDetailViewModel.AsyncActionCreator!
  private var notificationToken: NotificationToken?

  static func make(for item: ItemRecord) -> ItemDetailViewController {
    let vc = StoryboardScene.ItemDetail.itemDetail.instantiate()
    vc.itemRecord = item
    let store = ItemDetailViewModel.make()
    vc.store = store
    vc.actionCreator = ItemDetailViewModel.AsyncActionCreator(store: store)
    return vc
  }

  deinit {
    self.notificationToken?.invalidate()
  }

}

// MARK: - lifecycles
extension ItemDetailViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.configure()

    self.bind(store: store)

    self.markdownView.load(markdown: item.body)

    self.actionCreator.startProgress()

    self.actionCreator.checkStockAndLikes(item: item)

    try? self.itemRecord.touch()
  }
}

// MARK: - uiactions
extension ItemDetailViewController {
  @IBAction private func onTapUser(sender: UIButton) {
    Dispatcher.shared.dispatch(action: Navigator.Link.user(user: item.user))
  }
}

// MARK: - private
private extension ItemDetailViewController {

  func configure() {
    self.notificationToken = self.itemRecord.observe { [weak self] _ in
      if let likesCount = self?.itemRecord.likesCount.value {
        self?.likesCountLabel.text = "\(likesCount)"
      }
    }
    titleLabel.text = item.title.removingHTMLEntities
    commentsCountLabel.text = "\(item.commentsCount)"
    userNameLabel.text = item.user.id
    createdDateLabel.text = item.createdDateString
    userImageView.kf.setImage(with: item.user.profileImageUrl?.minq_asURL)
    self.userImageView.minq.circulize()
    self.mainScroller.isScrollEnabled = true
    self.tagsScroller.scrollsToTop = false
    self.tagsStackView.minq.arrangeTags(of: item)
    self.hidesBottomBarWhenPushed = true
    self.contentView.minq.fill(with: self.markdownView)
    self.markdownView.isScrollEnabled = false
    self.markdownView.onRendered = { [weak self] height in
      self?.store.dispatch(action: ItemDetailViewModel.Action.transition(to: .done))
    }

    self.markdownView.onTouchLink = { [weak self] request in
      guard let actionCreator = self?.actionCreator else { return false }
      guard let url = request.url else { return false }

      if let itemId = url.minq_qiitaItemId {
        try? actionCreator.load(by: itemId)
      } else if UIApplication.shared.canOpenURL(url) {
        Dispatcher.shared.dispatch(
          action: Navigator.Link.url(url: url))
      }
      return false
    }

    self.navigationItem.rightBarButtonItems = [
      likeButton,
      stockButton,
      safariButton
    ]
  }

  func bind(store: ItemDetailViewModel.ItemDetailStore) {
    store.state.viewState.asDriver()
      .drive(onNext: { [weak self] state in
        self?.loader?.removeFromSuperview()
        switch state {
        case .initial:
          break
        case .loading:
          self?.progressBar.minq.animate(to: .start)
        case .requesting:
          let loader = LoadingStateView.loadFromNib()
          loader.backgroundColor = Asset.Colors.black.color.withAlphaComponent(0.8)
          self?.view.minq.attach(loader)
          self?.loader = loader
        case .done:
          self?.actionCreator.stopProgress()
          self?.progressBar.minq.animate(to: .complete)
        case .failed:
          self?.actionCreator.stopProgress()
          self?.progressBar.minq.animate(to: .fail)
          self?.showSorryView()
        }
      }).disposed(by: self.disposeBag)

    store.state.progress.asDriver().drive(onNext: { [weak self] progress in
      self?.progressBar.setProgress(progress, animated: true)
    }).disposed(by: self.disposeBag)

    store.state.likeButtonState.asDriver().drive(onNext: { [weak self] state in
      guard let _self = self else { return }
      switch state {
      case .initial:
        _self.likeButton.isEnabled = false
      case .checked:
        _self.likeButton.isEnabled = true
        _self.likeButton.image = AppInfo.likedImage
        _self.likeButton.action = #selector(_self.unlikeItem)
        _self.likeButton.tintColor = Asset.Colors.green.color
      case .unchecked:
        _self.likeButton.isEnabled = true
        _self.likeButton.image = AppInfo.unlikedImage
        _self.likeButton.action = #selector(_self.likeItem)
        _self.likeButton.tintColor = Asset.Colors.gray.color
      }
    }).disposed(by: self.disposeBag)

    store.state.stockButtonState.asDriver().drive(onNext: { [weak self] state in
      guard let _self = self else { return }
      switch state {
      case .initial:
        _self.stockButton.isEnabled = false
      case .checked:
        _self.stockButton.isEnabled = true
        _self.stockButton.image = AppInfo.stockedImage
        _self.stockButton.action = #selector(_self.unstockItem)
        _self.stockButton.tintColor = Asset.Colors.green.color
      case .unchecked:
        _self.stockButton.isEnabled = true
        _self.stockButton.image = AppInfo.unstockedImage
        _self.stockButton.action = #selector(_self.stockItem)
        _self.stockButton.tintColor = Asset.Colors.gray.color
      }
    }).disposed(by: self.disposeBag)
  }

  @objc func likeItem() {
    self.actionCreator.like(item: item)
  }

  @objc func unlikeItem() {
    self.actionCreator.unlike(item: item)
  }

  @objc func stockItem() {
    self.actionCreator.stock(item: item)
  }

  @objc func unstockItem() {
    self.actionCreator.unstock(item: item)
  }

  @objc func openInSafari() {
    guard let url = try? item.url.asURL() else { return }
    UIApplication.shared.open(url)
  }

  func showSorryView() {
    self.sorryImage.image = UIImage.fontAwesomeIcon(
      name: .warning,
      textColor: Asset.Colors.yellow.color,
      size: CGSize(width: 64, height: 64)
    )
    self.contentView.minq.fill(with: self.sorryView)
  }
}
