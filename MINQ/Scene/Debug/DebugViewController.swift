import UIKit
import Crashlytics

final class DebugViewController: UIViewController {
  @IBOutlet weak var buildNumberLabel: UILabel!
  @IBOutlet weak var bundleIdLabel: UILabel!
}

// MARK: - lifecycles
extension DebugViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    self.buildNumberLabel.text = AppInfo.buildNumber
    self.bundleIdLabel.text = AppInfo.bundleID
  }
}

// MARK: - private
private extension DebugViewController {

  @IBAction func onDismiss() {
    self.dismiss(animated: true, completion: nil)
  }
}
