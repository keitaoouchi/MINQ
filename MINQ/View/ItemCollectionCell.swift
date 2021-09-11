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

  private let tagsCollection: TagsCollectionViewController = {
    TagsCollectionViewController(item: nil)
  }()

  private let statsView: StatsView = {
    StatsView.loadFromNib()
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(articleTitleLabel)
    contentView.addSubview(tagsCollection.view)
    contentView.addSubview(statsView)
    articleTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    tagsCollection.view.translatesAutoresizingMaskIntoConstraints = false
    statsView.translatesAutoresizingMaskIntoConstraints = false

    let margin = Style.Margin.itemCollection
    NSLayoutConstraint.activate([
      articleTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin.top),
      articleTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin.left),
      articleTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: margin.right),
      tagsCollection.view.topAnchor.constraint(equalTo: articleTitleLabel.bottomAnchor, constant: 8.0),
      tagsCollection.view.leadingAnchor.constraint(equalTo: articleTitleLabel.leadingAnchor),
      tagsCollection.view.trailingAnchor.constraint(equalTo: articleTitleLabel.trailingAnchor),
      statsView.topAnchor.constraint(equalTo: tagsCollection.view.bottomAnchor, constant: 4.0),
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
    tagsCollection.update(item: item)
    statsView.apply(item: item)

    contentView.invalidateIntrinsicContentSize()
  }
}
