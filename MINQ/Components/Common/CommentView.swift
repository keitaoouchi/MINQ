import UIKit
import MarkdownView

final class CommentView: UIView {
  private let markdownView: MarkdownView = {
    let md = MarkdownView()
    md.isScrollEnabled = false
    md.onRendered = { [weak md] height in
      md?.heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    return md
  }()

  private let userButton = UserButton()

  private var onTouchUser: (() -> Void)?

  func apply(comment: Comment, onTouchLink: @escaping ((URLRequest) -> Bool), onTouchUser: @escaping (() -> Void)) {
    addSubview(markdownView)
    addSubview(userButton)
    markdownView.translatesAutoresizingMaskIntoConstraints = false
    userButton.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      markdownView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
      markdownView.leadingAnchor.constraint(equalTo: leadingAnchor),
      markdownView.trailingAnchor.constraint(equalTo: trailingAnchor),
      userButton.topAnchor.constraint(equalTo: markdownView.bottomAnchor, constant: 8),
      userButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
      userButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
    ])

    markdownView.onTouchLink = onTouchLink
    self.onTouchUser = onTouchUser

    markdownView.load(markdown: comment.body, css: Markdown.CSS.markdown, styled: false)
    userButton.set(user: comment.user)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    userButton.addAction(.init { [weak self] _ in self?.onTouchUser?() }, for: .touchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
