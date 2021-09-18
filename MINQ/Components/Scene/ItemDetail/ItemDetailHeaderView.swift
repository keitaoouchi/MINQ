//
//  ItemDetailHeaderView.swift
//  MINQ
//
//  Created by keeeita on 2021/06/27.
//  Copyright © 2021 keeeita. All rights reserved.
//

import UIKit
import Reusable
import FontAwesome_swift

final class ItemDetailHeaderView: UIView {
  private let titleLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 36, weight: .bold)
    label.textColor = .label
    return label
  }()

  private let statsView: StatsView = StatsView()

  private let createdDateLabel: UILabel = {
    let label = UILabel(frame: .zero)
    label.numberOfLines = 0
    label.font = .systemFont(ofSize: 12.0)
    label.textColor = .secondaryLabel
    label.textAlignment = .right
    return label
  }()

  init(item: Item) {
    super.init(frame: .zero)

    titleLabel.text = item.title.removingHTMLEntities()
    createdDateLabel.text = item.createdDateString
    statsView.apply(item: item)
    let stackView = UIStackView(arrangedSubviews: [
      titleLabel,
      statsView,
      createdDateLabel
    ])
    stackView.axis = .vertical
    stackView.spacing = 8
    stackView.alignment = .fill
    minq.attach(stackView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
