import UIKit

final class LoadingStateView: UIView, ComplementalStateView {
  let indicator: UIActivityIndicatorView

  init(style: UIActivityIndicatorView.Style) {
    indicator = LoadingStateView.makeActivityIndicator(style: style)
    super.init(frame: .zero)

    minq.fill(with: indicator)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private static func makeActivityIndicator(style: UIActivityIndicatorView.Style) -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView(style: style)
    indicator.color = Asset.Colors.green.color
    indicator.startAnimating()
    return indicator
  }
}
