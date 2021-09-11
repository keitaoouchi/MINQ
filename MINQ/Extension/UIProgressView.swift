import UIKit

enum UIProgressViewAnimationType {
  case start
  case complete
  case fail
  case hide
}

extension MINQExtension where Base: UIProgressView {

  func animate(to type: UIProgressViewAnimationType) {
    switch type {
    case .start:
      startProgressView()
    case .complete:
      completeProgressView()
    case .fail:
      failProgressView()
    case .hide:
      hidesProgressView()
    }
  }

  private func completeProgressView() {
    self.base.setProgress(1.0, animated: false)
    UIView.animate(
      withDuration: 0.3,
      delay: 0.0,
      options: .curveEaseInOut,
      animations: {
        self.base.layoutIfNeeded()
      },
      completion: { _ in
        self.hidesProgressView()
      }
    )
  }

  private func startProgressView() {
    self.base.setProgress(0.1, animated: false)
    UIView.animate(
      withDuration: 0.1,
      animations: {
        self.base.layoutIfNeeded()
      }
    )
  }

  private func failProgressView() {
    self.base.setProgress(0.0, animated: false)
    UIView.animate(
      withDuration: 2.0,
      delay: 0.0,
      options: .curveEaseIn,
      animations: {
        self.base.layoutIfNeeded()
      },
      completion: { _ in
        self.hidesProgressView()
      }
    )
  }

  private func hidesProgressView() {
    UIView.animate(
      withDuration: 0.3,
      delay: 0.4,
      options: .curveEaseInOut,
      animations: {
        self.base.alpha = 0
      },
      completion: { _ in
        self.base.isHidden = true
      }
    )
  }

}
