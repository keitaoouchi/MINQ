import FBSnapshotTestCase
@testable import MINQ

class MINQSnapshotTestCase: FBSnapshotTestCase {
  override func setUp() {
    super.setUp()
    
    TestHelper.configureDB()
    Authentication.clear()
    API.resetProvider()
  }
  
  override func tearDown() {
    super.tearDown()
  }
}
