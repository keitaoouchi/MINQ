import UIKit

extension MINQExtension where Base: UIImage {

  func resized(to width: CGFloat) -> UIImage {
    let scale = width / base.size.width
    let height = base.size.height * scale
    UIGraphicsBeginImageContext(CGSize(width: width, height: height))
    base.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return result!
  }
}
