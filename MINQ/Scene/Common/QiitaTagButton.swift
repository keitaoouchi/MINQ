import UIKit
import RxSwift
import FluxxKit

final class QiitaTagButton: UIButton {

  private var subscription: Disposable?

  deinit {
    self.subscription?.dispose()
  }

  var qiitaTag: Tag? {
    didSet {
      let title = NSAttributedString(
        string: qiitaTag?.name ?? "",
        attributes: [
          NSAttributedStringKey.underlineStyle: NSUnderlineStyle.styleSingle.rawValue]
      )
      self.setAttributedTitle(title, for: .normal)
      self.invalidateIntrinsicContentSize()

      self.subscription?.dispose()
      self.subscription = self.rx.tap.asDriver().drive(onNext: { [weak self] _ in
        guard let tag = self?.qiitaTag else { return }
        Dispatcher.shared.dispatch(action: Navigator.Link.tag(tag: tag))
      })
    }
  }

  override var intrinsicContentSize: CGSize {
    let size = super.intrinsicContentSize
    return CGSize(
      width: size.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
      height: size.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom
    )
  }

  fileprivate func setUp() {
    self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    titleLabel?.font = UIFont.systemFont(ofSize: AppInfo.tagSize)
    titleLabel?.textColor = Asset.Colors.gray.color
    titleLabel?.clipsToBounds = true
    backgroundColor = .white
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setUp()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }

}
