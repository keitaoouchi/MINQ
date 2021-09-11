import UIKit
import Reusable

final class ChannelHeader: UICollectionReusableView, Reusable {
  private let titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.text = L10n.na
    label.numberOfLines = 1
    label.font = Style.Font.channelCollectionHeader
    label.textColor = .magenta
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)

    minq.attach(titleLabel, top: 12, leading: 16, trailing: 0, bottom: -12)
    backgroundColor = Asset.Colors.bg.color
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func apply(_ title: String) {
    titleLabel.text = title
  }
}
