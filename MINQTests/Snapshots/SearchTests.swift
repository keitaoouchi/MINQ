import FBSnapshotTestCase
import FluxxKit
import RealmSwift
@testable import MINQ

class SearchTests: MINQSnapshotTestCase {
  
  var window: UIWindow!
  
  override func setUp() {
    super.setUp()
    self.recordMode = false
    // stop real api request
    TestHelper.stubAPI()
    let vc = StoryboardScene.Search.initialScene.instantiate()
    window = UIWindow()
    window.rootViewController = vc
    window.makeKeyAndVisible()
    TestHelper.wait(for: 0.0)
  }
  
  func testInit() {
    TestFixture.items.forEach {
      try! ItemRecord.save(entity: $0)
    }
    let realm = try! Realm()
    try! realm.write {
      realm.objects(ItemRecord.self).setValue(Date(), forKey: "readAt")
    }
    TestHelper.wait(for: 1.0)
    FBSnapshotVerifyView(window)
  }
}
