import UIKit
import MarkdownView
import Kingfisher
import WebKit
import RxSwift
import FluxxKit
import HTMLString
import RealmSwift

final class ItemDetailViewController: UIViewController {
  @IBOutlet private weak var progressBar: UIProgressView!
  @IBOutlet private weak var contentView: UIView!

  private lazy var likeButton: UIBarButtonItem = {
    return UIBarButtonItem(image: Icon.unlikedImage, style: .done, target: self, action: nil)
  }()

  private lazy var stockButton: UIBarButtonItem = {
    return UIBarButtonItem(image: Icon.unstockedImage, style: .done, target: self, action: nil)
  }()

  private lazy var safariButton: UIBarButtonItem = {
    return UIBarButtonItem(image: Icon.safariImage, style: .done, target: self, action: #selector(openInSafari))
  }()

  private lazy var commentsbutton: UIBarButtonItem = {
    return UIBarButtonItem(image: Icon.commentsImage, style: .done, target: self, action: #selector(showComments))
  }()

  private(set) var item: Item!

  private let disposeBag = DisposeBag()
  private let markdownView = MarkdownView()
  private var tagsView = TagsView()
  private(set) var store: ItemDetailViewModel.ItemDetailStore!
  private(set) var actionCreator: ItemDetailViewModel.AsyncActionCreator!
  private var notificationToken: NotificationToken?

  static func make(for item: Item) -> ItemDetailViewController {
    let vc = StoryboardScene.ItemDetail.itemDetail.instantiate()
    vc.item = item
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

    layout()

    configureMarkdown()

    bind(store: store)

    actionCreator.startProgress()

    actionCreator.checkStockAndLikes(item: item)

    try? ItemRepository.touch(item)
  }
}

// MARK: - actions
extension ItemDetailViewController {
  @IBAction private func onTapUser(sender: UIButton) {
    Dispatcher.shared.dispatch(action: Navigator.Link.user(item.user))
  }

  @objc func likeItem() {
    actionCreator.like(item: item)
  }

  @objc func unlikeItem() {
    actionCreator.unlike(item: item)
  }

  @objc func stockItem() {
    actionCreator.stock(item: item)
  }

  @objc func unstockItem() {
    actionCreator.unstock(item: item)
  }

  @objc func openInSafari() {
    guard let url = try? item.url.asURL() else { return }
    UIApplication.shared.open(url)
  }

  @objc func showComments() {
    let vc = CommentsViewController(item: item)
    navigationController?.present(vc, animated: true, completion: nil)
  }
}

// MARK: - layout
private extension ItemDetailViewController {

  func layout() {
    view.backgroundColor = Asset.Colors.bg.color
    contentView.backgroundColor = Asset.Colors.bg.color
    hidesBottomBarWhenPushed = true
    tagsView.apply(tags: item.tags)

    let headerView = ItemDetailHeaderView(item: item)
    headerView.translatesAutoresizingMaskIntoConstraints = false
    tagsView.translatesAutoresizingMaskIntoConstraints = false
    markdownView.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(headerView)
    contentView.addSubview(tagsView)
    contentView.addSubview(markdownView)

    let margin = Style.Margin.itemDetail
    NSLayoutConstraint.activate([
      headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin.top),
      headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin.left),
      headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: margin.right),
      tagsView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0),
      tagsView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
      tagsView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
      markdownView.topAnchor.constraint(equalTo: tagsView.bottomAnchor, constant: 16),
      markdownView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: -8.0),
      markdownView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 8.0),
      markdownView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: margin.bottom)
    ])

    navigationItem.rightBarButtonItems = [
      likeButton,
      stockButton,
      safariButton
    ]
    if item.commentsCount > 0 {
      navigationItem.rightBarButtonItems?.append(commentsbutton)
    }
  }
}

// MARK: - MISC

extension ItemDetailViewController {

  func configureMarkdown() {
    markdownView.isScrollEnabled = false
    markdownView.onRendered = { [weak self] _ in
      self?.store.dispatch(action: ItemDetailViewModel.Action.transition(to: .done))
    }

    markdownView.onTouchLink = { request in
      guard let url = request.url else { return false }

      if let itemId = url.minq_qiitaItemId {
        Dispatcher.shared.dispatch(action: Navigator.Link.itemId(itemId))
      } else {
        Dispatcher.shared.dispatch(action: Navigator.Link.url(url))
      }
      return false
    }

    markdownView.load(markdown: item.body,
                      css: Markdown.CSS.markdown,
                      plugins: Markdown.JS.plugins,
                      stylesheets: Markdown.Stylesheet.stylesheets,
                      styled: false)
  }

  func bind(store: ItemDetailViewModel.ItemDetailStore) {
    store.state.viewState.asDriver()
      .drive(onNext: { [weak self] state in
        switch state {
        case .initial:
          break
        case .loading:
          self?.progressBar.minq.animate(to: .start)
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
      guard let self = self else { return }
      switch state {
      case .initial:
        self.likeButton.isEnabled = false
      case .checked:
        self.likeButton.isEnabled = true
        self.likeButton.image = Icon.likedImage
        self.likeButton.action = #selector(self.unlikeItem)
        self.likeButton.tintColor = Asset.Colors.green.color
      case .unchecked:
        self.likeButton.isEnabled = true
        self.likeButton.image = Icon.unlikedImage
        self.likeButton.action = #selector(self.likeItem)
        self.likeButton.tintColor = .secondaryLabel
      }
    }).disposed(by: self.disposeBag)

    store.state.stockButtonState.asDriver().drive(onNext: { [weak self] state in
      guard let self = self else { return }
      switch state {
      case .initial:
        self.stockButton.isEnabled = false
      case .checked:
        self.stockButton.isEnabled = true
        self.stockButton.image = Icon.stockedImage
        self.stockButton.action = #selector(self.unstockItem)
        self.stockButton.tintColor = Asset.Colors.green.color
      case .unchecked:
        self.stockButton.isEnabled = true
        self.stockButton.image = Icon.unstockedImage
        self.stockButton.action = #selector(self.stockItem)
        self.stockButton.tintColor = .secondaryLabel
      }
    }).disposed(by: disposeBag)
  }

  func showSorryView() {
    contentView.subviews.first { $0 is MarkdownView }?.removeFromSuperview()
    let sorryView = SorryView.loadFromNib()
    sorryView.translatesAutoresizingMaskIntoConstraints = false
    contentView.addSubview(sorryView)
    NSLayoutConstraint.activate([
      sorryView.topAnchor.constraint(equalTo: tagsView.bottomAnchor, constant: 0),
      sorryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
      sorryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
      sorryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
    ])
  }
}

extension ItemDetailViewController {
  // We are willing to become first responder to get shake motion
  override var canBecomeFirstResponder: Bool {
    true
  }

  // Enable detection of shake motion
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    let vc = CommentsViewController(item: item)
    navigationController?.present(vc, animated: true, completion: nil)
  }
}
