import UIKit
import Reusable
import FluxxKit

final class TagsCollectionViewController: UICollectionViewController {
  var item: Item?

  init(item: Item?) {
    self.item = item

    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    layout.sectionInset = UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 8)
    super.init(collectionViewLayout: layout)
    collectionView.showsVerticalScrollIndicator = false
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.automaticallyAdjustsScrollIndicatorInsets = false
    collectionView.heightAnchor.constraint(equalToConstant: 32).isActive = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Lifecycle

extension TagsCollectionViewController: UICollectionViewDelegateFlowLayout {

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.register(cellType: TagsCollectionCell.self)

    self.configureUI()
  }
}

// MARK: - MISC

extension TagsCollectionViewController {

  func update(item: Item) {
    self.item = item
    self.collectionView.reloadData()
  }

  func configureUI() {
    collectionView.backgroundColor = .clear

    let tagLabel = UILabel()
    tagLabel.font = Style.FontAwesome.tagMark
    tagLabel.text = String.fontAwesomeIcon(name: .tags)
    tagLabel.textColor = .secondaryLabel.withAlphaComponent(0.5)
    tagLabel.backgroundColor = Asset.Colors.bg.color
    tagLabel.textAlignment = .center
    tagLabel.widthAnchor.constraint(equalToConstant: 24).isActive = true

    view.addSubview(tagLabel)
    tagLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      tagLabel.topAnchor.constraint(equalTo: view.topAnchor),
      tagLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tagLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }

  override func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return item?.tags.count ?? 0
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(for: indexPath) as TagsCollectionCell
    let tag = item!.tags[indexPath.row]
    cell.apply(name: tag.name)
    return cell
  }

  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let tag = item!.tags[indexPath.row]
    Dispatcher.shared.dispatch(action: Navigator.Link.tag(tag))
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let tag = item!.tags[indexPath.row].name
    let label = UILabel(frame: .zero)
    label.font = Style.Font.tag
    label.text = tag
    return label.systemLayoutSizeFitting(
      CGSize(width: UIView.layoutFittingCompressedSize.width,
             height: 28),
      withHorizontalFittingPriority: .fittingSizeLevel,
      verticalFittingPriority: .fittingSizeLevel
    )
  }
}

final class TagsCollectionCell: UICollectionViewCell, Reusable {
  let label: UILabel = {
    let label = UILabel()
    label.font = Style.Font.tag
    label.textColor = .secondaryLabel
    label.attributedText = NSAttributedString(
      string: "N/A",
      attributes: [
        NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
      ]
    )
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.minq.fill(with: label)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func apply(name: String) {
    self.label.minq.updateAttributeText(name)
  }
}
