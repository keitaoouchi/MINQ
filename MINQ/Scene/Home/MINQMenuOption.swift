import PagingMenuController

struct MINQMenuItem: MenuItemViewCustomizable {
  let title: String

  var displayMode: MenuItemDisplayMode {
    return .text(
      title: MenuItemText(text: title,
                          color: .white,
                          selectedColor: .white,
                          font: UIFont.systemFont(ofSize: AppInfo.menuItemFontSize),
                          selectedFont: UIFont.systemFont(ofSize: AppInfo.menuItemFontSize, weight: .bold))
    )
  }
}

struct MINQMenuOptions: MenuViewCustomizable {
  let titles: [String]

  var height: CGFloat {
    return AppInfo.menuViewHeight
  }

  var backgroundColor: UIColor { return Asset.Colors.green.color }

  var selectedBackgroundColor: UIColor { return Asset.Colors.green.color }

  var menuSelectedItemCenter: Bool { return true }

  var focusMode: MenuFocusMode { return .none }

  var menuPosition: MenuPosition { return .top }

  var displayMode: MenuDisplayMode {
    if UIDevice.current.userInterfaceIdiom == .pad {
      if titles.count < 8 {
        return .segmentedControl
      } else {
        return .infinite(widthMode: .flexible, scrollingMode: .scrollEnabled)
      }
    } else {
      return .infinite(widthMode: .flexible, scrollingMode: .scrollEnabled)
    }
  }

  var itemsOptions: [MenuItemViewCustomizable] {
    return titles.map { MINQMenuItem(title: $0) }
  }
}

struct MINQMenu: PagingMenuControllerCustomizable {
  private let vcs: [ItemTableViewController]

  init(vcs: [ItemTableViewController]) {
    self.vcs = vcs
  }

  var componentType: ComponentType {
    return .all(
      menuOptions: MINQMenuOptions(
        titles: self.vcs.map { $0.query.type.title }
      ),
      pagingControllers: vcs
    )
  }
}
