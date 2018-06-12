import FBSnapshotTestCase
import FluxxKit
import RealmSwift
@testable import MINQ

class SettingsTests: MINQSnapshotTestCase {
  
  var window: UIWindow!
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
    TestHelper.stubAPI()
    let vc = StoryboardScene.Settings.initialScene.instantiate()
    window = UIWindow()
    window.rootViewController = vc
    window.makeKeyAndVisible()
    TestHelper.wait(for: 0.0)
  }
  
  func testRequesting() {
    Dispatcher.shared.dispatch(action: SettingsViewModel.Transition.view(to: .requesting))
    FBSnapshotVerifyView(window)
  }
  
  func testAnonymouse() {
    Dispatcher.shared.dispatch(action: SettingsViewModel.Transition.view(to: .anonymouse))
    FBSnapshotVerifyView(window)
  }
  
  func testSignedin() {
    Dispatcher.shared.dispatch(action: SettingsViewModel.Transition.view(to: .signed(user: TestFixture.user)))
    FBSnapshotVerifyView(window)
  }
}
