import UIKit

extension IndexPath {
  func isTail(in collectionView: UICollectionView) -> Bool {
    return section + 1 == collectionView.numberOfSections &&
      row + 1 == collectionView.numberOfItems(inSection: collectionView.numberOfSections - 1)
  }
}
