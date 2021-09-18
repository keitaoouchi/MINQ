import UIKit
import Kingfisher
import FontAwesome_swift
import RxCocoa
import RxSwift
import Reusable
import FluxxKit

final class ItemCollectionCell: UICollectionViewCell, Reusable {
  private let articleTitleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = L10n.na
    label.numberOfLines = 0
    label.font = Style.Font.itemCollectionTitle
    label.textColor = .label
    return label
  }()

  private let tagsView: TagsView = TagsView()

  private let statsView: StatsView = StatsView()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(articleTitleLabel)
    contentView.addSubview(tagsView)
    contentView.addSubview(statsView)
    articleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    tagsView.translatesAutoresizingMaskIntoConstraints = false
    statsView.translatesAutoresizingMaskIntoConstraints = false

    let margin = Style.Margin.itemCollection
    NSLayoutConstraint.activate([
      articleTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin.top),
      articleTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin.left),
      articleTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: margin.right),
      tagsView.topAnchor.constraint(equalTo: articleTitleLabel.bottomAnchor, constant: 8.0),
      tagsView.leadingAnchor.constraint(equalTo: articleTitleLabel.leadingAnchor),
      tagsView.trailingAnchor.constraint(equalTo: articleTitleLabel.trailingAnchor),
      statsView.topAnchor.constraint(equalTo: tagsView.bottomAnchor, constant: 4.0),
      statsView.leadingAnchor.constraint(equalTo: articleTitleLabel.leadingAnchor),
      statsView.trailingAnchor.constraint(equalTo: articleTitleLabel.trailingAnchor),
      statsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: margin.bottom)
    ])
    selectedBackgroundView = UIView(frame: .zero)
    selectedBackgroundView?.backgroundColor = .separator
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func apply(item: Item) {
    articleTitleLabel.text = item.title.removingHTMLEntities()
    tagsView.apply(tags: item.tags)
    statsView.apply(item: item)

    contentView.invalidateIntrinsicContentSize()
  }
}
