import FBSnapshotTestCase
import FluxxKit
import RealmSwift
@testable import MINQ

class ItemDetailTests: MINQSnapshotTestCase {
  
  var window: UIWindow!
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
    TestHelper.stubAPI()
    try! ItemRecord.save(entity: TestFixture.item)
    let record = try! ItemRecord.find(by: TestFixture.item.id)!
    let vc = ItemDetailViewController.make(for: record)
    let nav = UINavigationController(rootViewController: vc)
    window = UIWindow()
    window.rootViewController = nav
    window.makeKeyAndVisible()
    TestHelper.wait(for: 0.0)
  }
  
  func testDone() {
    TestHelper.wait(for: 3.0)
    Dispatcher.shared.dispatch(action: ItemDetailViewModel.Action.transition(to: .done))
    FBSnapshotVerifyView(window)
  }
}
