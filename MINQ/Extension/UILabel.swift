import UIKit

extension MINQExtension where Base: UILabel {
  func updateAttributeText(_ text: String) {
    if let attributedText = base.attributedText,
       let copy = attributedText.mutableCopy() as? NSMutableAttributedString {
      copy.mutableString.setString(text)
      base.attributedText = copy
    }
  }
}
