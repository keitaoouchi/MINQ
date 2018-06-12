import UIKit

final class BorderedButton: UIButton {
  @IBInspectable var borderColor: UIColor = UIColor.clear
  @IBInspectable var borderWidth: CGFloat = 0.0
  @IBInspectable var cornerRadius: CGFloat = 10.0

  override func draw(_ rect: CGRect) {
    super.draw(rect)

    self.layer.borderColor = borderColor.cgColor
    self.layer.borderWidth = borderWidth
    self.layer.cornerRadius = cornerRadius
    self.layer.masksToBounds = true
    if isEnabled {
      self.alpha = 1.0
    } else {
      self.alpha = 0.6
    }
  }

  func setEnabledWithAnimation(isEnabled: Bool) {
    if isEnabled {
      UIView.animate(withDuration: 0.5) {
        self.alpha = 1.0
      }
    } else {
      UIView.animate(withDuration: 0.33) {
        self.alpha = 0.6
      }
    }
  }
}
