import FBSnapshotTestCase
import FluxxKit
@testable import MINQ

class HomeTests: MINQSnapshotTestCase {
  
  var window: UIWindow!
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
    // stop real api request
    TestHelper.stubAPI()
    let vc = StoryboardScene.Home.initialScene.instantiate()
    window = UIWindow()
    window.rootViewController = vc
    window.makeKeyAndVisible()
    TestHelper.wait(for: 0.5)
  }
  
  func testDone() {
    try! ItemCollectionRecord.save(of: .latest, with: TestFixture.items, paging: nil)
    Dispatcher.shared.dispatch(action: ItemTableViewModel.Transition.request(to: .done(paging: nil)))
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(window)
  }
  
  func testEmpty() {
    Dispatcher.shared.dispatch(action: ItemTableViewModel.Transition.request(to: .empty))
    FBSnapshotVerifyView(window)
  }
  
  func testFailed() {
    Dispatcher.shared.dispatch(action: ItemTableViewModel.Transition.request(to: .failed(error: APIError.mappingError)))
    FBSnapshotVerifyView(window)
  }
  
  func testLoading() {
    Dispatcher.shared.dispatch(action: ItemTableViewModel.Transition.request(to: .requesting))
    FBSnapshotVerifyView(window)
  }
  
  func testAuthRequired() {
    Dispatcher.shared.dispatch(action: ItemTableViewModel.Transition.request(to: .authRequired))
    FBSnapshotVerifyView(window)
  }
}
