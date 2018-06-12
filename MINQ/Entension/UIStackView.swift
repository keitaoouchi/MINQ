import UIKit

extension MINQExtension where Base: UIStackView {

  func arrangeTags(of item: Item) {
    for sv in self.base.arrangedSubviews {
      self.base.removeArrangedSubview(sv)
      sv.removeFromSuperview()
    }
    let tagLabel = UILabel()
    tagLabel.font = UIFont.fontAwesome(ofSize: AppInfo.tagSize)
    tagLabel.text = String.fontAwesomeIcon(name: .tags)
    tagLabel.textColor = Asset.Colors.gray.color
    tagLabel.backgroundColor = .white
    self.base.addArrangedSubview(tagLabel)
    for tag in item.tags {
      let button = QiitaTagButton()
      button.qiitaTag = tag
      self.base.addArrangedSubview(button)
    }
  }

}
