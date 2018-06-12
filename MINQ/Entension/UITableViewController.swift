import UIKit
import RealmSwift

extension MINQExtension where Base: UITableViewController {

  func apply<T>(changes: RealmCollectionChange<T>) {
    switch changes {
    case .initial, .update:
      self.base.tableView.reloadData()
    case .error(let error):
      Debugger.shared.error("[MINQ][REALM] \(error)")
    }
  }

  func apply(status: ViewState,
             onReload: ((UIButton) -> Void)? = nil) {
    self.hideLoadingFooterView()

    switch status {
    case .initial:
      self.showInitial()
    case .authRequired:
      self.showAuthRequired()
    case .requesting:
      self.showLoading()
    case .failed:
      self.base.tableView.refreshControl?.endRefreshing()
      self.showError(onTapReloadButton: onReload)
    case .empty:
      self.base.tableView.refreshControl?.endRefreshing()
      self.showEmpty(onTapReloadButton: onReload)
    case .reloading:
      break
    case .paginating:
      self.showLoadingFooterView()
    case .done:
      self.base.tableView.refreshControl?.endRefreshing()
      self.showContents()
      self.base.tableView.reloadData()
    }
  }

  func showEmpty(onTapReloadButton: ((UIButton) -> Void)? = nil) {
    self.removeStateView()
    let empty = EmptyStateView.loadFromNib()
    self.base.view.addSubview(empty)
    empty.frame = self.base.view.bounds
    empty.onTapReloadButton = onTapReloadButton
  }

  func showError(onTapReloadButton: ((UIButton) -> Void)? = nil) {
    self.removeStateView()
    let failed = FailedStateView.loadFromNib()
    self.base.view.addSubview(failed)
    failed.frame = self.base.view.bounds
    failed.onTapReloadButton = onTapReloadButton

  }

  func showInitial() {
    self.removeStateView()
    let initial = InitialStateView()
    self.base.view.addSubview(initial)
    initial.frame = self.base.view.bounds
  }

  func showLoading() {
    self.removeStateView()
    let loader = LoadingStateView.loadFromNib()
    self.base.view.addSubview(loader)
    loader.frame = self.base.view.bounds
  }

  func showAuthRequired() {
    self.removeStateView()
    let authView = AuthRequiredView.loadFromNib()
    self.base.view.addSubview(authView)
    authView.frame = self.base.view.bounds
  }

  func showContents() {
    self.base.view.subviews.forEach { subView in
      if subView is InitialStateView ||
        subView is AuthRequiredView ||
        subView is EmptyStateView ||
        subView is LoadingStateView ||
        subView is FailedStateView {
        let animation = UIViewPropertyAnimator(duration: 0.33, curve: .easeInOut)
        animation.addAnimations({
          subView.alpha = 0.0
        })
        animation.addCompletion({ _ in
          subView.removeFromSuperview()
        })
        animation.startAnimation()
      }
    }
  }

  private func removeStateView() {
    self.base.view.subviews.forEach { subView in
      if subView is InitialStateView ||
        subView is AuthRequiredView ||
        subView is EmptyStateView ||
        subView is LoadingStateView ||
        subView is FailedStateView {
        subView.removeFromSuperview()
      }
    }
  }

  /// tableView.tableFooterViewにUIActivityIndicatorViewを設定して表示
  func showLoadingFooterView() {
    if let spinner = self.base.tableView.tableFooterView as? UIActivityIndicatorView {
      spinner.alpha = 1.0
      spinner.isHidden = false
      spinner.frame.size.height = 44.0
      spinner.startAnimating()
    } else {
      let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
      spinner.color = Asset.Colors.green.color
      spinner.startAnimating()
      spinner.frame = CGRect(x: 0.0, y: 0.0, width: self.base.tableView.bounds.width, height: 44.0)
      self.base.tableView.tableFooterView = spinner
    }
  }

  /// tableView.tableFooterViewを非表示化
  func hideLoadingFooterView() {
    guard let spinner = self.base.tableView.tableFooterView as? UIActivityIndicatorView else {
      return
    }

    let animation = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut)
    animation.addAnimations {
      spinner.alpha = 0.0
    }
    animation.addCompletion { _ in
      spinner.stopAnimating()
      spinner.alpha = 1.0
      spinner.frame.size.height = 0.0
    }
    animation.startAnimation()
  }

  // コンテンツがあればトップ位置までスクロールさせる
  func scrollToTop(animated: Bool) {
    if self.base.tableView.numberOfRows(inSection: 0) > 0 {
      let index = IndexPath(row: 0, section: 0)
      self.base.tableView.scrollToRow(at: index, at: .top, animated: animated)
    }
  }
}
