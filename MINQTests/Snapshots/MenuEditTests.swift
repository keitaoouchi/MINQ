import FBSnapshotTestCase
import FluxxKit
import RealmSwift
@testable import MINQ

class MenuEditTests: MINQSnapshotTestCase {
  
  var window: UIWindow!
  let currentTags = TestFixture.tags.prefix(through: 5).map { $0 }
  let followingTags = TestFixture.tags.suffix(5).map { $0 }
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
    TestHelper.stubAPI()
    let vc = StoryboardScene.MenuEdit.initialScene.instantiate()
    let nav = UINavigationController(rootViewController: vc)
    window = UIWindow()
    window.rootViewController = nav
    window.makeKeyAndVisible()
    TestHelper.wait(for: 0.0)
  }
  
  func testNoTags() {
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.currentTags(state: .empty))
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.followingTags(state: .empty))
    FBSnapshotVerifyView(window)
  }
  
  func testDone() {
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.currentTags(state: .initialized(tags: currentTags)))
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.followingTags(state: .done(tags: followingTags)))
    FBSnapshotVerifyView(window)
  }
  
  func testRequesting() {
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.currentTags(state: .empty))
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.followingTags(state: .requesting))
    FBSnapshotVerifyView(window)
  }
  
  func testAnonymouse() {
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.currentTags(state: .empty))
    Dispatcher.shared.dispatch(action: MenuEditViewModel.Transition.followingTags(state: .authRequired))
    FBSnapshotVerifyView(window)
  }
}
