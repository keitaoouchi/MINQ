import UIKit
import RxSwift
import MarkdownView
import FluxxKit

final class CommentsViewController: UIViewController {
  private let viewModel: CommentsViewModel
  private let disposeBag = DisposeBag()

  init(item: Item) {
    viewModel = CommentsViewModel(item: item)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = Asset.Colors.bg.color

    viewModel.store.state.requestState.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] state in
      switch state {
      case .requesting:
        let loader = LoadingStateView(style: .large)
        loader.backgroundColor = Asset.Colors.bg.color
        self?.view.minq.fill(with: loader)
      case .done(let comments):
        self?.showContents(comments)
      case .empty:
        self?.view.minq.removeComplementalStateView()
        self?.view.minq.fill(with: EmptyStateView.loadFromNib())
      case .failed:
        self?.view.minq.removeComplementalStateView()
        let errorView = FailedStateView.loadFromNib()
        errorView.onTapReloader = { [weak self] _ in
          self?.viewModel.start()
        }
        self?.view.minq.fill(with: errorView)
      }
    }).disposed(by: disposeBag)

    viewModel.start()
  }

  private func showContents(_ comments: [Comment]) {
    let stack = UIStackView()
    stack.axis = .vertical
    comments.reversed().forEach { comment in
      let commentView = CommentView(frame: .zero)
      stack.addArrangedSubview(commentView)
      commentView.apply(
        comment: comment,
        onTouchLink: { [weak self] request in
          guard let url = request.url else { return false }

          if let itemId = url.minq_qiitaItemId {
            self?.dismiss(animated: true, completion: {
              Dispatcher.shared.dispatch(action: Navigator.Link.itemId(itemId))
            })
          } else {
            self?.dismiss(animated: true, completion: {
              Dispatcher.shared.dispatch(
                action: Navigator.Link.url(url))
            })
          }
          return false
        },
        onTouchUser: { [weak self] in
          self?.dismiss(animated: true, completion: {
            Dispatcher.shared.dispatch(
              action: Navigator.Link.user(comment.user))
          })
        }
      )

      let separator = UIView(frame: .zero)
      separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
      separator.backgroundColor = .separator
      stack.addArrangedSubview(separator)
    }
    stack.arrangedSubviews.last?.removeFromSuperview()

    let base = UIView(frame: .zero)
    base.minq.attach(stack, top: 8, leading: 16, trailing: -16, bottom: -8)
    let scroller = UIScrollView()
    scroller.showsHorizontalScrollIndicator = false
    scroller.minq.fill(with: base)

    let bar = UIView(frame: .zero)
    bar.heightAnchor.constraint(equalToConstant: 6).isActive = true
    bar.widthAnchor.constraint(equalToConstant: 128).isActive = true
    bar.backgroundColor = .separator
    bar.layer.cornerRadius = 3.0
    bar.layer.masksToBounds = true
    let barContainer = UIView(frame: .zero)
    barContainer.minq.centered(with: bar)
    barContainer.heightAnchor.constraint(equalToConstant: 32).isActive = true

    view.addSubview(barContainer)
    view.addSubview(scroller)
    barContainer.translatesAutoresizingMaskIntoConstraints = false
    scroller.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      barContainer.topAnchor.constraint(equalTo: view.topAnchor),
      barContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      barContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: barContainer.bottomAnchor),
      scroller.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scroller.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])

    base.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true

    // マークダウンの描画に伴ってレイアウトがごちゃっとなるので一時非表示にして
    // 描画が終わったと思われるタイミングで表示
    scroller.isHidden = true
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(comments.count)) {
      self.view.minq.removeComplementalStateView()
      scroller.isHidden = false
    }
  }
}
